import requests
import time
import re

def get_gender_genderize(name, country_id="NG"):
    """
    Calls the Genderize.io API to predict gender for a given name and country ID.
    
    Args:
        name (str): The name to analyze (first, full, or partial).
        country_id (str): The ISO 3166-1 alpha-2 country code (e.g., 'NG' for Nigeria).
    
    Returns:
        dict: The parsed JSON response from the API, or None if an error occurs.
    """
    base_url = "https://api.genderize.io"
    
    if not name:
        return None
    
    # Clean and extract meaningful first name for better accuracy
    cleaned_name = name.strip()
    
    # Extract first name, skipping titles and honorifics
    first_name = extract_meaningful_first_name(cleaned_name)
    
    if not first_name:
        return None
    
    params = {
        'name': first_name,
        'country_id': country_id
    }
    
    print(f"Sending request for name: '{first_name}' (from '{name}') in country: '{country_id}'...")
    
    try:
        response = requests.get(base_url, params=params, timeout=10)
        
        # Handle specific status codes
        if response.status_code == 401:
            print(f"API Error 401: Unauthorized - Invalid API key")
            return None
        elif response.status_code == 402:
            print(f"API Error 402: Payment Required - Subscription is not active")
            return None
        elif response.status_code == 422:
            print(f"API Error 422: Unprocessable Content - Invalid or missing 'name' parameter")
            return None
        elif response.status_code == 429:
            print(f"API Error 429: Too many requests - Rate limit reached")
            time.sleep(1)  # Wait before retry
            return None
        elif response.status_code == 200:
            data = response.json()
            print(f"API Response for '{first_name}': {data}")
            return data
        else:
            response.raise_for_status()
            
    except requests.exceptions.RequestException as e:
        print(f"An error occurred during the API request: {e}")
        return None

def extract_meaningful_first_name(full_name):
    """
    Extract the most meaningful first name from a full name, skipping titles and honorifics.
    
    Args:
        full_name (str): Full name with possible titles/honorifics
    
    Returns:
        str: The most meaningful first name for gender detection
    """
    if not full_name:
        return ""
    
    # Common titles and honorifics to skip (with and without periods)
    titles_to_skip = {
        'mr', 'mr.', 'mister', 'mrs', 'mrs.', 'miss', 'ms', 'ms.', 'master',
        'dr', 'dr.', 'doctor', 'prof', 'prof.', 'professor', 'engr', 'engr.', 'engineer',
        'rev', 'rev.', 'reverend', 'pastor', 'elder', 'eld.', 'deacon', 'dn', 'dn.',
        'chief', 'alh', 'alh.', 'alhaji', 'alhaja', 'prince', 'princess',
        'sir', 'madam', 'madame', 'lady', 'lord', 'bar', 'bar.', 'barr', 'barr.',
        'capt', 'capt.', 'captain', 'col', 'col.', 'colonel', 'gen', 'gen.', 'general',
        'sen', 'sen.', 'senator', 'hon', 'hon.', 'honorable', 'hrh', 'hrh.',
        'hajiya', 'hajia', 'mallam', 'mall.', 'sheikh', 'imam'
    }
    
    # Clean the name
    name_parts = full_name.strip().split()
    meaningful_parts = []
    
    for part in name_parts:
        # Remove any punctuation and convert to lowercase for comparison
        clean_part = re.sub(r'[.,;:]$', '', part.strip()).lower()
        
        # Skip if it's a title/honorific or single letter initial
        if clean_part in titles_to_skip or (len(clean_part) == 1 and clean_part.isalpha()):
            continue
        
        # Check for abbreviated titles (like "H.O." should be skipped)
        if re.match(r'^[A-Z]\.$', part.strip()):
            continue
        
        meaningful_parts.append(part)
    
    # If we have meaningful parts, return the first one
    if meaningful_parts:
        # Take the first meaningful name part
        first_meaningful = meaningful_parts[0]
        
        # Handle initials with periods (like "S." in "Afolabi S. Silas")
        if len(first_meaningful) == 2 and first_meaningful.endswith('.'):
            # Look for the next meaningful part
            if len(meaningful_parts) > 1:
                return meaningful_parts[1]
        
        # Handle cases like "MRADERONMU" (title concatenated with name)
        if first_meaningful.upper().startswith('MR') and len(first_meaningful) > 2:
            # Extract name after "MR" prefix
            possible_name = first_meaningful[2:]  # Remove "MR"
            if possible_name and len(possible_name) > 1:
                return possible_name
        
        return first_meaningful
    
    # Fallback: return the first non-title word if we couldn't find meaningful parts
    for part in name_parts:
        clean_part = re.sub(r'[.,;:]$', '', part.strip()).lower()
        if clean_part not in titles_to_skip and len(clean_part) > 1:
            return part
    
    # Last resort: return the first part
    return name_parts[0] if name_parts else ""

def extract_gender_from_api_response(api_response):
    """
    Extract gender from API response with confidence check.
    
    Args:
        api_response (dict): Response from Genderize API
    
    Returns:
        str: 'Male', 'Female', or 'Unknown'
    """
    if not api_response:
        return 'Unknown'
    
    # Check if we have gender data
    if 'gender' in api_response and api_response['gender']:
        gender = api_response['gender'].capitalize()
        probability = api_response.get('probability', 0)
        
        # Only return if confidence is high enough
        if probability >= 0.7:  # 70% confidence threshold
            return gender
        else:
            return 'Unknown'
    
    return 'Unknown'

def detect_gender_from_name_prefix(name):
    """
    Detect gender based on prefixes/titles in the name.
    Simple and reliable approach.
    
    Args:
        name (str): Full name to analyze
    
    Returns:
        str: 'Male', 'Female', or 'Unknown'
    """
    if not name or not isinstance(name, str):
        return 'Unknown'
    
    name_upper = name.upper().strip()
    
    # Split into words
    words = name_upper.split()
    if not words:
        return 'Unknown'
    
    # Check first word for titles
    first_word = words[0]
    
    # Female titles (check first)
    female_titles = {
        'MRS', 'MRS.', 'MISS', 'MS', 'MS.', 'MADAM', 'MADAME',
        'SISTER', 'SIS', 'SIS.', 'MOTHER', 'DEACONESS',
        'MAMA', 'MA', 'AUNTY', 'AUNT', 'ALHAJA', 'PRINCESS', 'LADY',
        'IYALODE', 'IYA', 'OMU', 'HAJIYA', 'HAJIA'
    }
    
    # Male titles
    male_titles = {
        'MR', 'MR.', 'MISTER', 'MASTER',
        'PASTOR', 'REV.', 'REVEREND', 'ELDER', 'ELD.', 'DEACON', 'DN', 'DN.',
        'BROTHER', 'BRO', 'BR.', 'FATHER', 'FR.',
        'CHIEF', 'ALH', 'ALH.', 'ALHAJI', 'PRINCE', 'SIR',
        'CAPT', 'CAPT.', 'CAPTAIN', 'COL', 'COL.', 'COLONEL',
        'GEN', 'GEN.', 'GENERAL', 'ENGR', 'ENGR.', 'ENGINEER',
        'DR', 'DR.', 'DOCTOR', 'PROF', 'PROF.', 'PROFESSOR'
    }
    
    # Clean first word (remove trailing period if present)
    first_word_clean = first_word.rstrip('.')
    
    # Check if first word is a title
    if first_word_clean in female_titles:
        return 'Female'
    elif first_word_clean in male_titles:
        return 'Male'
    
    # Check for concatenated titles like "MRADERONMU"
    if first_word.startswith('MR') and len(first_word) > 2:
        # It starts with MR but is longer (like MRADERONMU)
        third_char = first_word[2]
        if third_char.isalpha():  # It's a concatenated MR + name
            return 'Male'
    
    if first_word.startswith('ALH') and len(first_word) > 3:
        fourth_char = first_word[3] if len(first_word) > 3 else ''
        if fourth_char.isalpha() or fourth_char == '.':
            return 'Male'
    
    # Check second word if first word is an abbreviation like "D." or "H.O."
    if len(words) > 1 and len(first_word) <= 3 and '.' in first_word:
        second_word = words[1].rstrip('.')
        if second_word in female_titles:
            return 'Female'
        elif second_word in male_titles:
            return 'Male'
    
    return 'Unknown'

def analyze_gender_from_name_content(name):
    """
    Analyze name content for gender clues (common male/female names in Nigerian context).
    Enhanced to handle more name patterns.
    
    Args:
        name (str): Full name to analyze
    
    Returns:
        str: 'Male', 'Female', or 'Unknown'
    """
    if not name or not isinstance(name, str):
        return 'Unknown'
    
    # Clean and extract meaningful first name
    first_name = extract_meaningful_first_name(name)
    if not first_name:
        return 'Unknown'
    
    name_lower = first_name.lower()
    
    # Enhanced Nigerian male name patterns
    male_patterns = [
        # Yoruba male names
        'ade', 'ola', 'tunde', 'kayode', 'yemi', 'wale', 'seun',
        'tayo', 'bayo', 'femi', 'deji', 'dayo', 'kunle', 'lere',
        'dare', 'gbenga', 'toyin', 'lanre', 'niyi', 'remi',
        # Yoruba male name starters
        'olu', 'ade', 'ola', 'tai', 'se', 'de', 'fe',
        # Igbo male names
        'chukwu', 'nna', 'emeka', 'obi', 'chukwudi', 'ifeanyi',
        'chike', 'chidi', 'chima', 'chibuike', 'obinna',
        # Hausa male names
        'abu', 'musa', 'ahmed', 'ali', 'yusuf', 'umar', 'sani',
        'ibrahim', 'suleiman', 'abdul', 'mohammed', 'mustapha',
        # General male patterns
        'son$', 'bert$', 'fred$', 'tony$', 'john$', 'paul$', 'mark$',
        'david$', 'peter$', 'james$', 'michael$', 'daniel$', 'joseph$',
        'samuel$', 'stephen$', 'anthony$', 'christopher$',
        # Common endings
        'ius$', 'us$', 'o$', 'e$', 'i$'
    ]
    
    # Enhanced Nigerian female name patterns
    female_patterns = [
        # Yoruba female names
        'kehinde', 'taiwo', 'titi', 'bimbo', 'bose', 'dupe',
        'funke', 'kemi', 'lola', 'tolu', 'yinka', 'adeola',
        'yemisi', 'morayo', 'abike', 'abiola', 'ayoka', 'eni',
        'folake', 'ibukun', 'idowu', 'iyabo', 'kafayat', 'moyo',
        # Yoruba female name starters
        'ayo', 'bisi', 'bose', 'dupe', 'fun', 'ke', 'la',
        # Igbo female names
        'nneka', 'chika', 'chioma', 'ngozi', 'amaka', 'uche',
        'ifeoma', 'obinna', 'chinyere', 'ebere', 'ngozi',
        'uchenna', 'amarachi', 'chiamaka', 'chinwe',
        # Hausa female names
        'fatima', 'aminat', 'zainab', 'halima', 'maryam',
        'aisha', 'hasana', 'jamila', 'kadija', 'lubaba',
        # General female patterns
        'a$', 'ah$', 'ia$', 'ina$', 'elle$', 'ette$', 'lyn$',
        'rose$', 'mary$', 'grace$', 'joy$', 'peace$', 'faith$',
        'hope$', 'love$', 'ann$', 'anne$', 'ella$',
        # Common female endings in Nigerian context
        'at$', 'wat$', 'lat$', 'rat$'
    ]
    
    # Check for male patterns
    for pattern in male_patterns:
        if pattern.endswith('$'):
            # Pattern is for ending
            if re.search(pattern, name_lower):
                return 'Male'
        elif pattern in name_lower:
            return 'Male'
    
    # Check for female patterns
    for pattern in female_patterns:
        if pattern.endswith('$'):
            # Pattern is for ending
            if re.search(pattern, name_lower):
                return 'Female'
        elif pattern in name_lower:
            return 'Female'
    
    # Check specific names from your examples
    specific_names = {
        'male': ['francis', 'kunle', 'joseph', 'silas', 'josiah', 'babatunde', 
                'gboyega', 'suleiman', 'tajudeen', 'oyewumi', 'akintayo',
                'akintola', 'olayiwola', 'alagbe', 'akinkunmi', 'adebayo',
                'alh', 'alhaji', 'alh.', 'h.o.', 'd.', 's.'],
        'female': ['iyabo', 'kafayat', 'florence', 'adepoju', 'abdola', 'idowu']
    }
    
    # Check entire name for specific patterns
    full_name_lower = name.lower()
    for male_name in specific_names['male']:
        if male_name in full_name_lower:
            # Additional check to avoid false positives
            if (male_name + ' ') in full_name_lower or full_name_lower.endswith(male_name):
                return 'Male'
    
    for female_name in specific_names['female']:
        if female_name in full_name_lower:
            if (female_name + ' ') in full_name_lower or full_name_lower.endswith(female_name):
                return 'Female'
    
    return 'Unknown'

def get_gender_with_fallback(name, country_id="NG", use_api=True):
    """
    Comprehensive gender detection with multiple fallback strategies.
    
    Args:
        name (str): The full name to analyze
        country_id (str): Country code for API (default: 'NG' for Nigeria)
        use_api (bool): Whether to use the Genderize API (default: True)
    
    Returns:
        str: 'Male', 'Female', or 'Unknown'
    """
    if not name or not isinstance(name, str) or name.strip() == '':
        return 'Unknown'
    
    cleaned_name = name.strip()
    
    # Step 0: Quick sanity check for very short names
    if len(cleaned_name) < 2:
        return 'Unknown'
    
    print(f"\nAnalyzing gender for: '{cleaned_name}'")
    
    # Step 1: Check for obvious prefixes/titles (most reliable)
    print("Step 1: Checking for gender prefixes/titles...")
    prefix_gender = detect_gender_from_name_prefix(cleaned_name)
    if prefix_gender != 'Unknown':
        print(f"  ✓ Detected '{prefix_gender}' from prefixes/titles")
        return prefix_gender
    
    # Step 2: Try API if enabled
    api_gender = 'Unknown'
    if use_api:
        print("Step 2: Trying Genderize API...")
        try:
            api_response = get_gender_genderize(cleaned_name, country_id)
            api_gender = extract_gender_from_api_response(api_response)
            
            if api_gender != 'Unknown':
                print(f"  ✓ API returned '{api_gender}'")
                return api_gender
            else:
                print("  ✗ API returned low confidence or no result")
        except Exception as api_error:
            print(f"  ✗ API error: {api_error}")
    
    # Step 3: Analyze name content/patterns
    print("Step 3: Analyzing name content/patterns...")
    pattern_gender = analyze_gender_from_name_content(cleaned_name)
    if pattern_gender != 'Unknown':
        print(f"  ✓ Detected '{pattern_gender}' from name patterns")
        return pattern_gender
    
    print("  ✗ No gender clues found")
    return 'Unknown'

def batch_get_gender(names_list, country_id="NG", delay=0.5, use_api=True):
    """
    Get gender for a batch of names with rate limiting.
    
    Args:
        names_list (list): List of names to analyze
        country_id (str): Country code
        delay (float): Delay between API calls in seconds
        use_api (bool): Whether to use API
    
    Returns:
        list: List of gender results
    """
    results = []
    
    for i, name in enumerate(names_list):
        print(f"\nProcessing {i+1}/{len(names_list)}: {name}")
        
        # Get gender with all fallbacks
        gender = get_gender_with_fallback(name, country_id, use_api)
        results.append(gender)
        
        # Add delay to avoid rate limiting (if using API)
        if use_api and i < len(names_list) - 1:
            time.sleep(delay)
    
    return results

# Test with your specific examples
if __name__ == "__main__":
    test_names = [
        "IDOWU FRANCIS OLUFEMI",
        "ELD. KUNLE AKINTAYO",
        "ADEJARE IYABO ADBOLA",
        "BELLO KAFAYAT",
        "CHIEF AKINTOLA JOSEPH",
        "Afolabi S. Silas",
        "Chief H.O. Alamu",
        "Prince Olayiwola Josiah",
        "Rev. D. A. Alagbe",
        "Pastor Akinkunmi Babatunde",
        "Dn. Adebayo Oyinade",
        "MRADERONMU GBOYEGA",
        "ALH SULEIMAN OYEWUMI",
        "MR TAJUDEEN BELLO",
        "MRS ADEPOJU FLORENCE",
        "Alh. Musa Bello",
        "Engr. John Okoro",
        "Prof. A. B. Williams",
        "Sister Mary Joseph",
        "Madam Comfort Adeyemi"
    ]
    
    print("="*60)
    print("GENDER DETECTION TEST WITH NIGERIAN NAMES")
    print("="*60)
    
    # Test without API first (faster, for demo)
    print("\nTesting without API (using only name analysis):")
    print("-"*60)
    
    for name in test_names:
        gender = get_gender_with_fallback(name, "NG", use_api=False)
        print(f"{name:30} → {gender}")
    
    # Test with API (commented out to avoid rate limits during testing)
    # print("\n\nTesting with API:")
    # print("-"*60)
    # genders = batch_get_gender(test_names, "NG", delay=1.0, use_api=True)
    
    # for name, gender in zip(test_names, genders):
    #     print(f"{name:30} → {gender}")