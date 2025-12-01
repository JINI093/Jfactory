class CategoryModel {
  final String title;
  final List<String> subcategories;
  final Map<String, List<String>>? subSubcategories;
  final Map<String, List<String>>? subSubSubcategories;

  CategoryModel({
    required this.title,
    required this.subcategories,
    this.subSubcategories,
    this.subSubSubcategories,
  });
}

class CategoryData {
  static final List<CategoryModel> categories = [
    CategoryModel(
      title: '기계제작\n(파트별)',
      subcategories: [
        '설계/도면',
        '가공1\n*선반,밀링\n*연마,연삭\n*컷팅\n*5축/대형 가공',
        '가공2\n*절단\n*벤딩\n*절곡\n*용접',
        '조립',
        '전기 제어\n*PLC제어\n*PC제어\n*상위통신',
        '지그\n(JIG)',
        '*Feeder\n(피더)\n*컨베이어\n*이송기',
        '*프레임\n*제관\n*프로파일',
      ],
      subSubcategories: {
        '가공1\n*선반,밀링*연마,연삭\n*컷팅\n*5축/대형 가공': [
          '*선반,밀링',
          '*연마,연삭',
          '*컷팅',
          '*5축/대형 가공',
        ],
        '가공2\n*절단\n*벤딩\n*절곡\n*용접': [
          '*절단',
          '*벤딩',
          '*절곡',
          '*용접',
          '기타',
        ],
        '전기 제어\n*PLC제어\n*PC제어\n*상위통신': [
          '*PLC제어',
          '*PC제어',
          '*상위통신',
        ],
        '*Feeder\n(피더)\n*컨베이어\n*이송기': [
          '*피더',
          '*컨베이어',
          '*이송기',
        ],
        '*프레임\n*제관\n*프로파일': [
          '*프레임',
          '*제관',
          '*프로파일',
        ],
      },
      subSubSubcategories: {
        '*컷팅': [
          '레이저',
          '와이어',
          '방전',
          '초음파',
          '워터젯',
        ],
        '*5축/대형 가공': [
          '5축 가공',
          '대형 가공',
          '기타',
        ],
      },
    ),
    CategoryModel(
      title: '인쇄',
      subcategories: [
        '패드 인쇄',
        '실크/스크린\n인쇄',
        'UV 프린트',
        '레이저 마킹',
        '핫스템핑\n(열전사)',
        '*옵셋 인쇄\n*그라비어 인쇄'
      ],
    ),
    CategoryModel(
      title: '사출\n(공병, 플라스틱, 유리 등)',
      subcategories: [
        'ABS',
        'PE',
        'PC',
        'PP',
        'Glass',
        '기타',
      ],
    ),
    CategoryModel(
      title: '*금형/몰드\n*3D 프린터',
      subcategories: [
        '몰드/포밍',
        '프레스 금형',
        '3D 프린터',
      ],
    ),
    CategoryModel(
      title: '기계제작\n(전체)',
      subcategories: [
        '유공압',
        '모터',
      ],
    ),
    CategoryModel(
      title: '공구 MALL',
      subcategories: [
        '공구',
        '전기 자재',
        '포장/케미칼',
        '볼트',
        '유공압',
        '모터',
        '베어링',
        '철강',
      ],
    ),
    CategoryModel(
      title: '*표면처리\n*건조기\n(열,UV,LED)',
      subcategories: [
        '프라즈마\n(화염/대기압 등)',
        '래핑/빠우',
        '도금/도장',
        '프라이머',
        '열 건조기',
        'UV 건조기',
        'LED 건조기',
      ],
    ),
    CategoryModel(
      title: '*Vision\n(비전)\n*Robot\n(무인화)',
      subcategories: [
        'Vision\n(비전)',
        '다관절\n(이송기)',
        '자율주행\n(이송기)',
        '인간로봇\n(Robot)',
      ],
    ),
  ];

  static List<List<CategoryModel>> get paginatedCategories {
    List<List<CategoryModel>> pages = [];
    for (int i = 0; i < categories.length; i += 8) {
      int end = (i + 8 < categories.length) ? i + 8 : categories.length;
      pages.add(categories.sublist(i, end));
    }
    return pages;
  }

  static CategoryModel? getCategoryByTitle(String title) {
    try {
      // Direct match first
      for (CategoryModel category in categories) {
        if (category.title == title) {
          return category;
        }
      }
      
      // Try with normalized title (replace \n with space)
      final normalizedTitle = title.replaceAll('\n', ' ');
      for (CategoryModel category in categories) {
        if (category.title == normalizedTitle) {
          return category;
        }
      }
      
      // Try with normalized category title (replace \n with space)
      for (CategoryModel category in categories) {
        final normalizedCategoryTitle = category.title.replaceAll('\n', ' ');
        if (normalizedCategoryTitle == title) {
          return category;
        }
      }
      
      // Case-insensitive match as fallback
      for (CategoryModel category in categories) {
        if (category.title.toLowerCase() == title.toLowerCase()) {
          return category;
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  static List<String>? getSubSubcategories(String categoryTitle, String subcategoryTitle) {
    try {
      final category = getCategoryByTitle(categoryTitle);
      if (category?.subSubcategories == null) return null;
      
      final normalizedTarget = _normalize(subcategoryTitle);
      for (final entry in category!.subSubcategories!.entries) {
        if (_normalize(entry.key) == normalizedTarget) {
          return entry.value;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static List<String>? getSubSubSubcategories(String categoryTitle, String subcategoryTitle, String subSubcategoryTitle) {
    try {
      final category = getCategoryByTitle(categoryTitle);
      final subSubSubcategories = category?.subSubSubcategories;
      if (subSubSubcategories == null) return null;

      final normalizedTarget = _normalize(subSubcategoryTitle);
      for (final entry in subSubSubcategories.entries) {
        if (_normalize(entry.key) == normalizedTarget) {
          return entry.value;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static bool hasSubSubcategories(String categoryTitle, String subcategoryTitle) {
    try {
      print('🔥 hasSubSubcategories called with categoryTitle: $categoryTitle, subcategoryTitle: $subcategoryTitle');
      final category = getCategoryByTitle(categoryTitle);
      print('🔥 Found category: ${category?.title}');
      if (category?.subSubcategories == null) {
        print('🔥 No subSubcategories found');
        return false;
      }
      
      print('🔥 Available keys: ${category!.subSubcategories!.keys}');
      
      final normalizedTarget = _normalize(subcategoryTitle);
      final hasSubSub = category.subSubcategories!.keys.any(
        (key) => _normalize(key) == normalizedTarget,
      );
      print('🔥 Exact match found: $hasSubSub');
      return hasSubSub;
    } catch (e) {
      print('🔥 Error in hasSubSubcategories: $e');
      return false;
    }
  }

  static bool hasSubSubSubcategories(String categoryTitle, String subcategoryTitle, String subSubcategoryTitle) {
    try {
      final category = getCategoryByTitle(categoryTitle);
      final subSubSubcategories = category?.subSubSubcategories;
      if (subSubSubcategories == null) {
        return false;
      }

      final normalizedTarget = _normalize(subSubcategoryTitle);
      final hasDetail = subSubSubcategories.keys.any(
        (key) => _normalize(key) == normalizedTarget,
      );
      return hasDetail;
    } catch (e) {
      return false;
    }
  }

  static String _normalize(String value) {
    return value.replaceAll(RegExp(r'\s+'), '');
  }
}