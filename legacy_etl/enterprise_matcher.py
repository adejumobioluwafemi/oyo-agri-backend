
import pandas as pd
import re  
from polyfuzz import PolyFuzz
from rapidfuzz import process, fuzz

# ======================================================
# ENTERPRISE MATCHER CLASS
# ======================================================
class EnterpriseMatcher:
    def __init__(self):
        # Initialize PolyFuzz models for each category
        self.crop_model = PolyFuzz("TF-IDF")
        self.livestock_model = PolyFuzz("TF-IDF")
        self.agro_model = PolyFuzz("TF-IDF")
        self.ignore_terms = {'plantation', 'farm', 'enterprise', 'production', 'cultivation'}
        
        # Your master lists
        self.MASTER_CROPS = [
            "maize", "sorghum", "cowpea", "cassava", "yam", "guineacorn", "millet",
            "rice", "cashew", "groundnut", "pepper", "vegetables", "oil palm",
            "sweet potato", "plantain", "melon", "soybeans", "cocoa", "potato", 
            "tomato", "sugar cane","cocoyam", "taro", "water yam", "white yam", "yellow yam",
            "ginger", "garlic", "onion", "okra", "eggplant", "garden egg",
            "pumpkin", "ugwu", "bitter leaf", "scent leaf", "moringa",
            "pineapple", "banana", "orange", "mango", "pawpaw", "guava",
            "avocado", "cashew apple", "soursop", "African star apple",
            "African breadfruit", "African oil bean", "bambara nut",
            "pigeon pea", "lablab bean", "velvet bean",
            
            # Tree crops
            "rubber", "coffee", "tea", "kolanut", "citrus", "grapefruit",
            "lemon", "lime", "tangerine", "almond", "date palm",
            
            # Spices and condiments
            "turmeric", "clove", "nutmeg", "alligator pepper", "black pepper",
            "thyme", "rosemary", "basil", "curry leaf",
            
            # Legumes and pulses
            "lentil", "mung bean", "kidney bean", "black-eyed pea",
            "adzuki bean", "fava bean",
            
            # Cereals and grains
            "wheat", "barley", "oats", "quinoa", "fonio", "acha",
            "african rice", "ofada rice", "nerica rice",
            
            # Roots and tubers
            "tannia", "arrowroot", "cassava leaf",
            
            # Fiber crops
            "cotton", "jute", "sisal", "kenaf",
            
            # Beverage crops
            "coffee arabica", "coffee robusta", "hibiscus", "ginger",
            
            # Others
            "castor", "neem", "jatropha", "sunflower", "sesame",
            "fluted pumpkin", "water leaf", "celosia", "amaranth",
            "bitter gourd", "snake gourd", "ridge gourd",
            
            # Common Nigerian names/varieties
            "ofada", "egusi", "agbado", "epa", "ewedu", "tete", "soko",
            "rodo", "atarodo", "tatashe", "shombo", "gbure", "efo",
            "ugu", "okazi", "oha", "nchanwu"
        ]
        
        self.MASTER_LIVESTOCK = [
            "cattle", "goat", "sheep", "poultry", "catfish", "bee", "pig", "fish", "cow",
            
            # Ruminants
            "bull", "ox", "calf", "ram", "ewe", "lamb", "buck", "doe", "kid",
            "buffalo", "water buffalo", "antelope", "deer",
            
            # Poultry
            "chicken", "broiler", "layer", "cock", "hen", "chick", "cockerel",
            "pullet", "turkey", "duck", "goose", "guinea fowl", "quail",
            "pigeon", "dove", "ostrich", "emu",
            
            # Swine
            "boar", "sow", "piglet", "hog", "swine",
            
            # Rabbits and small animals
            "rabbit", "hare", "grasscutter", "cane rat", "guinea pig",
            "snail", "giant african snail",
            
            # Fish and aquaculture
            "tilapia", "clarias", "heterobranchus", "heterotis",
            "parrot fish", "mudfish", "carp", "shrimp", "prawn",
            "crayfish", "lobster", "oyster", "mussel", "clam",
            
            # Bees and insects
            "honeybee", "apiculture", "beekeeping",
            
            # Dairy animals
            "dairy cow", "milking cow", "friesian", "holstein",
            "jersey", "sahiwal", "white fulani", "red bororo",
            "ndama", "keteku", "muturu",
            
            # Other
            "donkey", "horse", "mare", "stallion", "foal",
            "camel", "llama", "alpaca",
            
            # Nigerian breeds/varieties
            "wadara", "bunaji", "rahaji", "sokoto gudali",
            "balami", "uda", "yoruba", "west african dwarf goat",
            "sahelian", "maradi", "kano brown", "nigerian horse",
            "n'dama", "muturu", "keteku"
        ]
        
        self.MASTER_AGRO_BUSINESSES = {
            # Existing
            "local rice": ("rice mill", "local rice"),
            "locust bean": ("food processing", "locust bean"),
            "iru": ("food processing", "locust bean"),
            "shea butter": ("food processing", "shea butter"),
            "yam flour": ("food processing", "yam flour"),
            "garri": ("food processing", "garri"),
            "lafun": ("food processing", "cassava flour"),
            "cassava chips": ("food processing", "cassava chips"),
            "tapioca": ("food processing", "tapioca"),
            "fufu": ("food processing", "fufu"),
            "crusher": ("food processing", "crusher"),
            "produce merchant": ("merchant", "produce"),
            "produce store keeper": ("merchant", "produce"),
            "fish seller": ("merchant", "fish"),
            "seller": ("merchant", "produce"),
            "mongers": ("merchant", "produce"),
            
            # Food Processing
            "palm oil": ("oil processing", "palm oil"),
            "palm kernel oil": ("oil processing", "palm kernel"),
            "groundnut oil": ("oil processing", "groundnut oil"),
            "soybean oil": ("oil processing", "soybean oil"),
            "vegetable oil": ("oil processing", "vegetable oil"),
            "refined oil": ("oil processing", "vegetable oil"),
            "oil mill": ("oil processing", "palm oil"),
            "palm wine": ("beverage processing", "palm wine"),
            "zobo": ("beverage processing", "hibiscus"),
            "fruit juice": ("beverage processing", "fruit juice"),
            "soymilk": ("beverage processing", "soybean milk"),
            "kunu": ("beverage processing", "kunu"),
            "fura": ("dairy processing", "fura"),
            "yoghurt": ("dairy processing", "yoghurt"),
            "cheese": ("dairy processing", "cheese"),
            "wara": ("dairy processing", "wara"),
            "butter": ("dairy processing", "butter"),
            "ice cream": ("dairy processing", "ice cream"),
            "bread": ("bakery", "bread"),
            "cake": ("bakery", "cake"),
            "biscuit": ("bakery", "biscuit"),
            "chin chin": ("bakery", "chin chin"),
            "meat processing": ("meat processing", "meat"),
            "fish smoking": ("fish processing", "fish"),
            "fish drying": ("fish processing", "fish"),
            "crayfish drying": ("fish processing", "crayfish"),
            "snail farming": ("snail processing", "snail"),
            
            # Input Supply
            "seed supplier": ("input supply", "seeds"),
            "fertilizer dealer": ("input supply", "fertilizer"),
            "agrochemical dealer": ("input supply", "agrochemicals"),
            "veterinary supplier": ("input supply", "veterinary drugs"),
            "feed mill": ("input supply", "animal feed"),
            "agric equipment": ("input supply", "farm equipment"),
            "irrigation equipment": ("input supply", "irrigation"),
            
            # Farm Services
            "tractor hiring": ("farm services", "mechanization"),
            "harvesting service": ("farm services", "harvesting"),
            "spraying service": ("farm services", "spraying"),
            "ploughing service": ("farm services", "land preparation"),
            "extension service": ("farm services", "technical advice"),
            
            # Marketing and Trading
            "grain trader": ("trading", "grains"),
            "livestock trader": ("trading", "livestock"),
            "export business": ("trading", "export crops"),
            "wholesale produce": ("trading", "produce"),
            "retail produce": ("trading", "produce"),
            "market women": ("trading", "produce"),
            "aggregator": ("trading", "produce"),
            
            # Storage and Preservation
            "cold storage": ("storage", "perishables"),
            "warehousing": ("storage", "grains"),
            "silo operation": ("storage", "grains"),
            "grain storage": ("storage", "grains"),
            
            # Value Addition
            "cashew nut processing": ("nut processing", "cashew"),
            "groundnut processing": ("nut processing", "groundnut"),
            "cocoa processing": ("cocoa processing", "cocoa"),
            "coffee processing": ("coffee processing", "coffee"),
            "tea processing": ("tea processing", "tea"),
            "fruit canning": ("fruit processing", "fruit"),
            "vegetable canning": ("vegetable processing", "vegetables"),
            "tomato paste": ("tomato processing", "tomato"),
            "pepper sauce": ("sauce processing", "pepper"),
            
            # By-products
            "cassava peel": ("by-product", "cassava peel"),
            "palm kernel cake": ("by-product", "palm kernel cake"),
            "groundnut cake": ("by-product", "groundnut cake"),
            "soybean cake": ("by-product", "soybean cake"),
            "rice bran": ("by-product", "rice bran"),
            "wheat bran": ("by-product", "wheat bran"),
            
            # Organic/Natural Products
            "organic fertilizer": ("organic products", "fertilizer"),
            "compost": ("organic products", "fertilizer"),
            "vermicompost": ("organic products", "fertilizer"),
            "biochar": ("organic products", "soil amendment"),
            "neem oil": ("organic products", "pesticide"),
            
            # Others
            "mushroom farming": ("mushroom production", "mushroom"),
            "bee keeping": ("apiculture", "honey"),
            "honey production": ("apiculture", "honey"),
            "fish farming": ("aquaculture", "fish"),
            "snail farming": ("heliciculture", "snail"),
            "rabbit farming": ("cuniculture", "rabbit"),
            "piggery": ("swine production", "pig"),
            "poultry farming": ("poultry production", "poultry"),
            "dairy farming": ("dairy production", "milk"),
            
            # Common Nigerian terms
            "mai shayi": ("food service", "tea"),
            "mai bukateria": ("food service", "food"),
            "mai suya": ("food service", "meat"),
            "mai akara": ("food service", "bean cake"),
            "mai moi moi": ("food service", "bean pudding"),
            "mai puff puff": ("food service", "doughnut"),
        }
        
        # Fit the models
        self._fit_models()
    
    def _fit_models(self):
        """Fit PolyFuzz models with master lists."""
        # Fit crop model
        self.crop_model.fit(self.MASTER_CROPS, self.MASTER_CROPS)
        
        # Fit livestock model
        self.livestock_model.fit(self.MASTER_LIVESTOCK, self.MASTER_LIVESTOCK)
        
        # Fit agro-business model with keys
        agro_keys = list(self.MASTER_AGRO_BUSINESSES.keys())
        self.agro_model.fit(agro_keys, agro_keys)
    
    def match_crop(self, token, min_similarity=0.6):
        """
        Match token to a crop using PolyFuzz.
        
        Args:
            token (str): Token to match
            min_similarity (float): Minimum similarity score (0-1)
        
        Returns:
            tuple: (matched_crop, similarity_score) or (None, 0)
        """
        if not token:
            return None, 0
        
        result = self.crop_model.match([token], self.MASTER_CROPS)
        matches = result.get_matches().iloc[0]
        
        if matches['Similarity'] >= min_similarity:
            return matches['To'], matches['Similarity']
        
        # Try token set ratio as fallback
        match = process.extractOne(
            token, 
            self.MASTER_CROPS,
            scorer=fuzz.token_set_ratio,
            score_cutoff=70
        )
        
        if match:
            return match[0], match[1] / 100
        
        return None, 0
    
    def match_livestock(self, token, min_similarity=0.6):
        """Match token to livestock using PolyFuzz."""
        if not token:
            return None, 0
        
        result = self.livestock_model.match([token], self.MASTER_LIVESTOCK)
        matches = result.get_matches().iloc[0]
        
        if matches['Similarity'] >= min_similarity:
            return matches['To'], matches['Similarity']
        
        # Try token set ratio as fallback
        match = process.extractOne(
            token, 
            self.MASTER_LIVESTOCK,
            scorer=fuzz.token_set_ratio,
            score_cutoff=70
        )
        
        if match:
            return match[0], match[1] / 100
        
        return None, 0
    
    def match_agro_business(self, token, min_similarity=0.6):
        """
        Match token to agro-business using PolyFuzz.
        Returns tuple: (matched_key, business_type, primary_product, similarity)
        """
        if not token:
            return None, None, None, 0
        
        agro_keys = list(self.MASTER_AGRO_BUSINESSES.keys())
        result = self.agro_model.match([token], agro_keys)
        matches = result.get_matches().iloc[0]
        
        if matches['Similarity'] >= min_similarity:
            matched_key = matches['To']
            business_type, primary_product = self.MASTER_AGRO_BUSINESSES[matched_key]
            return matched_key, business_type, primary_product, matches['Similarity']
        
        # Try token set ratio as fallback
        match = process.extractOne(
            token, 
            agro_keys,
            scorer=fuzz.token_set_ratio,
            score_cutoff=70
        )
        
        if match:
            matched_key = match[0]
            business_type, primary_product = self.MASTER_AGRO_BUSINESSES[matched_key]
            return matched_key, business_type, primary_product, match[1] / 100
        
        return None, None, None, 0
    
    def split_enterprise_field(self, s: str):
        """
        Split enterprise field using PolyFuzz for better matching.
        
        Args:
            s (str): Enterprise field string
        
        Returns:
            list: List of enterprise tokens with their categories
        """
        if not isinstance(s, str):
            return []
        
        s_lower = s.lower().strip()
        if not s_lower:
            return []
        
        # First, try to split by common delimiters
        raw_parts = re.split(r'[,/;\\\-\s]+| and ', s_lower)
        raw_tokens = [p.strip() for p in raw_parts if p.strip()]
        
        # Try to combine adjacent tokens for multi-word matches
        combined_tokens = []
        i = 0
        while i < len(raw_tokens):
            # Try single token
            current_token = raw_tokens[i]
            
            # Try two-token combination
            if i + 1 < len(raw_tokens):
                two_token = f"{raw_tokens[i]} {raw_tokens[i+1]}"
            else:
                two_token = None
            
            # Try three-token combination
            if i + 2 < len(raw_tokens):
                three_token = f"{raw_tokens[i]} {raw_tokens[i+1]} {raw_tokens[i+2]}"
            else:
                three_token = None
            
            # Check which combination has the highest match score
            best_match = None
            best_score = 0
            best_token = None
            
            for token in [current_token, two_token, three_token]:
                if token:
                    # Check all categories
                    crop_match, crop_score = self.match_crop(token, min_similarity=0.4)
                    livestock_match, livestock_score = self.match_livestock(token, min_similarity=0.4)
                    agro_match, agro_btype, agro_pprod, agro_score = self.match_agro_business(token, min_similarity=0.4)
                    
                    max_score = max(crop_score, livestock_score, agro_score)
                    
                    if max_score > best_score:
                        best_score = max_score
                        best_token = token
                        if crop_score == max_score:
                            best_match = ('crop', crop_match)
                        elif livestock_score == max_score:
                            best_match = ('livestock', livestock_match)
                        else:
                            best_match = ('agro', agro_match)
            
            if best_score >= 0.6 and best_match and best_token:
                # Found a good match
                combined_tokens.append({
                    'token': best_token,
                    'category': best_match[0],
                    'matched_to': best_match[1],
                    'score': best_score
                })
                # Skip tokens that were combined
                if best_token == three_token:
                    i += 3
                elif best_token == two_token:
                    i += 2
                else:
                    i += 1
            else:
                # No good combination found, use single token
                combined_tokens.append({
                    'token': current_token,
                    'category': 'unknown',
                    'matched_to': None,
                    'score': 0
                })
                i += 1
        
        return combined_tokens
    
    def process_enterprise_field(self, enterprise_field):
        """
        Process enterprise field and return categorized tokens.
        
        Args:
            enterprise_field (str): Raw enterprise field
        
        Returns:
            dict: Dictionary with categorized results
        """
        if not enterprise_field or not isinstance(enterprise_field, str):
            return {'crops': [], 'livestock': [], 'agro': [], 'unknown': []}
        
        tokens_info = self.split_enterprise_field(enterprise_field)
        
        result = {
            'crops': [],
            'livestock': [],
            'agro': [],
            'unknown': []
        }
        
        for token_info in tokens_info:
            if token_info['category'] == 'crop' and token_info['score'] >= 0.7:
                result['crops'].append({
                    'token': token_info['token'],
                    'matched_crop': token_info['matched_to'],
                    'score': token_info['score']
                })
            elif token_info['category'] == 'livestock' and token_info['score'] >= 0.7:
                result['livestock'].append({
                    'token': token_info['token'],
                    'matched_livestock': token_info['matched_to'],
                    'score': token_info['score']
                })
            elif token_info['category'] == 'agro' and token_info['score'] >= 0.7:
                agro_key = token_info['matched_to']
                business_type, primary_product = self.MASTER_AGRO_BUSINESSES.get(agro_key, (None, None))
                result['agro'].append({
                    'token': token_info['token'],
                    'matched_key': agro_key,
                    'business_type': business_type,
                    'primary_product': primary_product,
                    'score': token_info['score']
                })
            else:
                if token_info['token'].lower() not in self.ignore_terms:
                    result['unknown'].append({
                        'token': token_info['token'],
                        'score': token_info['score']
                    })
        
        return result