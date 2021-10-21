import { jaroWinkler } from "jaro-winkler-typescript";
const termSimilarityThreshold = 0.8;


export class StringSimilarity {

    private _df: Map<string, number> = new Map<string, number>();


    constructor(corpus: string[]) {
        // in how many documents does a term occur...
        corpus.forEach((element: string) => {
            let terms = this._tokenise(element);
            terms.forEach((freq, term) => {
                let count: number | undefined = this._df.get(term);
                if (count) count++;
                else count = 1;
                this._df.set(term, count);
            });
        });
    }

    /**
     * Calculates the similarity between doc1 and doc2 in context of the corpus used the create this object.
     * Uses SoftTfIdf, see William W Cohen, Pradeep Ravikumar and Stephen (2003) ‘A Comparison of String Distance Metrics for’, Proceedings of the IJCAI-2003 Workshop on, pp. 73--78.
     * @param doc1 
     * @param doc2 
     */
    public calculateSimilarity(doc1: string, doc2: string): number {
        if (!doc1 || !doc2) return 0;
        if (doc1 === doc2) return 1;
        if (doc1.toLowerCase() === doc2.toLowerCase()) return 0.99;
        let tf1 = this._tokenise(doc1);
        let tf2 = this._tokenise(doc2);
        tf1 = this._tf2TfIdf(tf1);
        tf2 = this._tf2TfIdf(tf2);
        const length1 = this._calcVectorLength(tf1);
        const length2 = this._calcVectorLength(tf2);
        let similarity = 0;
        tf1.forEach((value1, term) => {
            if (tf2.has(term)) {
                let value2 = tf2.get(term) ?? 0;
                similarity += (value1 * value2);
            } else {
                // find similar term using Jaro-Winkler
                let bestMatch = { term: "", similarity: 0 };
                tf2.forEach((value2, term2) => {
                    let termSimilarity = jaroWinkler(term, term2);
                    if (termSimilarity > bestMatch.similarity) {
                        bestMatch = { term: term2, similarity: termSimilarity };
                    }
                });
                if (bestMatch.similarity >= termSimilarityThreshold) {
                    let value2 = tf2.get(bestMatch.term) ?? 0;
                    similarity += (value1 * value2 * bestMatch.similarity);
                }
            }
        });
        // normalise
        similarity = similarity / (length1 * length2);
        return similarity * 0.98; // max out at 98%
    }

    private _tokenise(document: string): Map<string, number> {
        const tf: Map<string, number> = new Map<string, number>();
        document.match(/\b(\w+)\b/g)?.forEach((word: string) => {
            word = word.toLowerCase();
            let count: number | undefined = tf.get(word);
            if (count) count++;
            else count = 1;
            tf.set(word, count);
        });
        return tf;
    }


    private _calcVectorLength(tf: Map<string, number>): number {
        let length = 0;
        tf.forEach((component, dimension) => {
            length += component ** 2;
        });

        return (length > 0) ? Math.sqrt(length) : 0;
    }

    private _tf2TfIdf(tf: Map<string, number>): Map<string, number> {
        const tfIdfArray: Map<string, number> = new Map<string, number>();
        tf.forEach((freq, term) => {
            const df = this._df.get(term) ?? 1;
            const idf = Math.log(this._df.size / df);
            const tfIdf = freq * idf;
            tfIdfArray.set(term, tfIdf);
        });
        return tfIdfArray;
    }
}
