using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Threading.Tasks;
using System.Web.Script.Serialization;

namespace TestApp
{




    class Program
    {



        static void ConvertPfx2Snk()
        {
            X509Certificate2 cert = new X509Certificate2(@"C:\Users\baenz\source\repos\ArtsCouncil\ArtsCouncil.Plugins\Perplex.pfx", "Perplex4ever", X509KeyStorageFlags.Exportable | X509KeyStorageFlags.PersistKeySet);
            RSACryptoServiceProvider provider = (RSACryptoServiceProvider)cert.PrivateKey;
            byte[] array = provider.ExportCspBlob(!provider.PublicOnly);
            using (FileStream fs = new FileStream(@"C:\Users\baenz\source\repos\ArtsCouncil\ArtsCouncil.Plugins\Perplex.snk", FileMode.Create, FileAccess.Write))
            {
                fs.Write(array, 0, array.Length);
            }
        }

        static void Main(string[] args)
        {
            stringFormatTest2();
            Console.WriteLine("Press any key to continue...");
            Console.ReadKey();
        }

        private static void stringFormatTest2()
        {
            var q = (@"
            <fetch version='1.0' output-format='xml-platform' mapping='logical' distinct='true' >
              <entity name='ace_bookmark' >
                <attribute name='ace_name' />
                <filter type='and' >
                  <condition attribute='ace_article' operator='eq' value='{0:D}' />
                  <condition attribute='ace_portaluser' operator='eq' value='{1}' />
                </filter>
              </entity>
            </fetch>
");
            q = string.Format(q, Guid.NewGuid(), Guid.NewGuid());
            Console.WriteLine(q);
        }

        static void stringFormatTest()
        {
            var message = "Bookmark deleted";
            string json = "{\n" +
                "\t\"Status\": \"Ok\",\n" +
                string.Format("\t\"Message\": \"{0}\",\n", message) +
                string.Format("\t\"Time\": \"{0}\"\n", DateTime.Now) +
                "}";
            Console.WriteLine(json);
        }

        static void JsonTest()
        {
            var json = @"    {
        ""Page"": ""manageBookmarks"",
        ""UserId"": ""0ede3a63-e97a-e911-a979-002248014773"",
        ""Action"": ""add"",
        ""ArticleId"": ""08d8ca0a-fba2-e911-a97b-00224801377b""
    }
";

            var jsSerializer = new JavaScriptSerializer();
            Dictionary<string, object> dict = (Dictionary<string, object>)jsSerializer.DeserializeObject(json);
            foreach (var kvp in dict)
            {
                Console.WriteLine("{0}: {1} ({2}: {3})", kvp.Key, kvp.Value, kvp.Key.GetType().Name, kvp.Value.GetType().Name);
            }
            Console.WriteLine("Press any key to continue...");
            Console.ReadKey();
        }
    }

}