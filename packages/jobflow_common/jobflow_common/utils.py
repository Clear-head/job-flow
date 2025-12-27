import re
from typing import Dict, Optional


def parse_address(scrap_address: str) -> Dict[str, Optional[str]]:
    if not scrap_address or not isinstance(scrap_address, str):
        return {"si": None, "gu": None, "detail_address": None}

    address = scrap_address.strip()

    si_patterns = [
        "서울특별시", "서울시", "서울",
        "부산광역시", "부산시", "부산",
        "대구광역시", "대구시", "대구",
        "인천광역시", "인천시", "인천",
        "광주광역시", "광주시", "광주",
        "대전광역시", "대전시", "대전",
        "울산광역시", "울산시", "울산",
        "세종특별자치시", "세종시", "세종",
        "경기도", "경기",
        "강원도", "강원특별자치도", "강원",
        "충청북도", "충북",
        "충청남도", "충남",
        "전라북도", "전북특별자치도", "전북",
        "전라남도", "전남",
        "경상북도", "경북",
        "경상남도", "경남",
        "제주특별자치도", "제주도", "제주",
    ]

    gu_pattern = r'([가-힣]+(?:구|군|시))'

    result = {"si": None, "gu": None, "detail_address": None}

    for si_name in si_patterns:
        if si_name in address:
            if si_name in ["서울", "서울시"]:
                result["si"] = "서울특별시"
            elif si_name in ["부산", "부산시"]:
                result["si"] = "부산광역시"
            elif si_name in ["대구", "대구시"]:
                result["si"] = "대구광역시"
            elif si_name in ["인천", "인천시"]:
                result["si"] = "인천광역시"
            elif si_name in ["광주", "광주시"]:
                result["si"] = "광주광역시"
            elif si_name in ["대전", "대전시"]:
                result["si"] = "대전광역시"
            elif si_name in ["울산", "울산시"]:
                result["si"] = "울산광역시"
            elif si_name in ["세종", "세종시"]:
                result["si"] = "세종특별자치시"
            elif si_name in ["경기"]:
                result["si"] = "경기도"
            elif si_name in ["강원", "강원특별자치도"]:
                result["si"] = "강원특별자치도"
            elif si_name in ["충북"]:
                result["si"] = "충청북도"
            elif si_name in ["충남"]:
                result["si"] = "충청남도"
            elif si_name in ["전북", "전북특별자치도"]:
                result["si"] = "전북특별자치도"
            elif si_name in ["전남"]:
                result["si"] = "전라남도"
            elif si_name in ["경북"]:
                result["si"] = "경상북도"
            elif si_name in ["경남"]:
                result["si"] = "경상남도"
            elif si_name in ["제주", "제주도"]:
                result["si"] = "제주특별자치도"
            else:
                result["si"] = si_name

            remaining = address.split(si_name, 1)[1].strip() if si_name in address else address
            break
    else:
        remaining = address

    if remaining:
        gu_matches = re.findall(gu_pattern, remaining)
        if gu_matches:
            if len(gu_matches) >= 2:
                result["gu"] = " ".join(gu_matches[:2])
                for gu in gu_matches[:2]:
                    remaining = remaining.replace(gu, "", 1).strip()
            else:
                result["gu"] = gu_matches[0]
                remaining = remaining.replace(gu_matches[0], "", 1).strip()

    if remaining:
        result["detail_address"] = remaining

    return result


def parse_salary(scrap_salary: str) -> Dict[str, Optional[int | bool]]:
    if not scrap_salary or not isinstance(scrap_salary, str):
        return {"salary_min": None, "salary_max": None, "salary_negotiable": False}

    salary_str = scrap_salary.strip().replace(" ", "").replace(",", "")

    result = {
        "salary_min": None,
        "salary_max": None,
        "salary_negotiable": False,
    }

    negotiable_keywords = ["협의", "면접후결정", "추후협의", "별도협의", "상담후결정"]
    if any(keyword in salary_str for keyword in negotiable_keywords):
        result["salary_negotiable"] = True
        return result

    def extract_number(text: str) -> Optional[int]:
        if "천만" in text or "천만원" in text:
            match = re.search(r'(\d+)천만', text)
            if match:
                return int(match.group(1)) * 1000

        if "억" in text:
            match = re.search(r'(\d+)억', text)
            if match:
                return int(match.group(1)) * 10000

        if "만" in text or "만원" in text:
            match = re.search(r'(\d+)만', text)
            if match:
                return int(match.group(1))

        match = re.search(r'(\d+)', text)
        if match:
            num = int(match.group(1))
            if num <= 100:
                return num * 1000
            return num

        return None

    range_patterns = [
        r'(\d+(?:억|천만|만)?원?)\s*~\s*(\d+(?:억|천만|만)?원?)',
        r'(\d+(?:억|천만|만)?원?)\s*-\s*(\d+(?:억|천만|만)?원?)',
        r'(\d+(?:억|천만|만)?원?)\s*에서\s*(\d+(?:억|천만|만)?원?)',
    ]

    for pattern in range_patterns:
        match = re.search(pattern, salary_str)
        if match:
            result["salary_min"] = extract_number(match.group(1))
            result["salary_max"] = extract_number(match.group(2))
            return result

    if "이상" in salary_str:
        match = re.search(r'(\d+(?:억|천만|만)?원?)', salary_str)
        if match:
            result["salary_min"] = extract_number(match.group(1))
            result["salary_max"] = None
            return result

    if "이하" in salary_str:
        match = re.search(r'(\d+(?:억|천만|만)?원?)', salary_str)
        if match:
            result["salary_min"] = None
            result["salary_max"] = extract_number(match.group(1))
            return result

    match = re.search(r'(\d+(?:억|천만|만)?원?)', salary_str)
    if match:
        salary = extract_number(match.group(1))
        result["salary_min"] = salary
        result["salary_max"] = salary
        return result

    return result


def normalize_tech_name(tech_name: str) -> str:
    if not tech_name:
        return ""

    normalized = tech_name.lower()

    special_cases = {
        "c++": "cpp",
        "c#": "csharp",
        ".net": "dotnet",
        "node.js": "nodejs",
        "vue.js": "vuejs",
        "next.js": "nextjs",
        "express.js": "expressjs",
    }

    if normalized in special_cases:
        return special_cases[normalized]

    normalized = re.sub(r'[^a-z0-9]', '', normalized)

    return normalized