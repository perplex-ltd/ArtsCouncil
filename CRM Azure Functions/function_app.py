import azure.functions as func
import logging
import re
import json

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

@app.route(route="ExtractPostMentions")
def ExtractPostMentions(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    post = req.params.get('post')
    if not post:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            post = req_body.get('post')

    if post:
       
        # Regular expression to match UUIDs enclosed in @[8,UUID,"name"]
        uuid_pattern = r'@\[8,([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}),"[^"]*"\]'
        # Find all matches in the input string
        uuids = re.findall(uuid_pattern, post)
        # Convert the list of UUIDs to a JSON array
        result = json.dumps(uuids)
        return func.HttpResponse(result)
    else:
        return func.HttpResponse(
             "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.",
             status_code=200
        )