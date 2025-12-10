# file: town_matcher.py

import re
import pandas as pd
from polyfuzz import PolyFuzz
from rapidfuzz import process, fuzz

class TownMatcher:
    def __init__(self, gazetteer_csv_path, embedding_model=None):
        """
        gazetteer_csv_path: CSV with at least columns: 'town', 'LGA', 'postalcode' (case-insensitive)
        embedding_model: optional model type for PolyFuzz (e.g. 'TF-IDF', 'EditDistance', 'Embeddings')
                         defaults to 'TF-IDF' if None.
        """
        self.town_df = pd.read_csv(gazetteer_csv_path, dtype=str)
        # normalize town names
        self.town_df['town_norm'] = self.town_df['town'].str.strip().str.lower()
        self.town_list = list(self.town_df['town_norm'].unique())

        method = embedding_model or "TF-IDF"
        self.pf = PolyFuzz(method)

        # we pre-fit the model on the gazetteer
        self.pf.fit(self.town_list)

    def preprocess(self, s: str) -> str:
        return re.sub(r'[\s\.,;]', ' ', s.strip().lower())

    def lookup_exact(self, town_norm: str):
        """Return gazetteer record if exact normalized match."""
        df = self.town_df[self.town_df['town_norm'] == town_norm]
        if not df.empty:
            return df.iloc[0]
        return None

    def match_with_polyfuzz(self, addr: str, min_similarity: float = 0.6):
        """
        Try to match full address string (normalized) to gazetteer via PolyFuzz.
        Returns best match (town_norm, similarity) or (None, 0.0).
        """
        cleaned = self.preprocess(addr)
        res = self.pf.match([cleaned], self.town_list)
        matches = res.get_matches().iloc[0]
        # PolyFuzz similarity is 0..1
        if matches['Similarity'] >= min_similarity:
            return matches['To'], matches['Similarity']
        return None, 0.0

    def token_fallback(self, addr: str, min_similarity: float = 80):
        """
        Split address on whitespace/punctuation and try fuzzy matching on each token.
        Returns first plausible gazetteer town_norm or None.
        """
        cleaned = self.preprocess(addr)
        tokens = [tok for tok in re.split(r'\s+', cleaned) if len(tok) >= 3]
        for tok in tokens:
            match = process.extractOne(tok, self.town_list,
                                      scorer=fuzz.token_set_ratio,
                                      score_cutoff=min_similarity,
                                      processor=None)
            if match:
                return match[0]
        return None

    def find(self, raw_addr: str):
        """
        Full lookup pipeline. Returns (town, LGA, postalcode, confidence, method)
        If none matched, returns (None, None, None, 0.0, 'none')
        """
        if not raw_addr or not isinstance(raw_addr, str):
            return (None, None, None, 0.0, 'none')

        norm = self.preprocess(raw_addr)

        # 1. exact normalized match
        rec = self.lookup_exact(norm)
        if rec is not None:
            return (rec['town'], rec['lga'], rec.get('postalcode'), 1.0, 'exact')

        # 2. try PolyFuzz full-string match
        town_norm, sim = self.match_with_polyfuzz(raw_addr, min_similarity=0.6)
        if town_norm:
            rec2 = self.town_df[self.town_df['town_norm'] == town_norm].iloc[0]
            return (rec2['town'], rec2['lga'], rec2.get('postalcode'), sim, 'polyfuzz')

        # 3. token-by-token fallback fuzzy match
        tok = self.token_fallback(raw_addr, min_similarity=80)
        if tok:
            rec3 = self.town_df[self.town_df['town_norm'] == tok].iloc[0]
            return (rec3['town'], rec3['lga'], rec3.get('postalcode'), None, 'token_fuzzy')

        # no match
        return (None, None, None, 0.0, 'none')
