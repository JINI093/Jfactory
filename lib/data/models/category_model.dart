class CategoryModel {
  final String title;
  final List<String> subcategories;
  final Map<String, List<String>>? subSubcategories;

  CategoryModel({
    required this.title,
    required this.subcategories,
    this.subSubcategories,
  });
}

class CategoryData {
  static final List<CategoryModel> categories = [
    CategoryModel(
      title: '기계 제작',
      subcategories: [
        '설계/도면',
        '가공1\n*선반,밀링\n*연마,연삭\n*컷팅\n*5축 가공기',
        '가공2\n*절단\n*벤딩\n*절곡\n*용접',
        '조립',
        '전기 제어\n*PLC\n*PC\n*상위통신',
        '지그\n(JIG)',
        '*Feeder\n(피더)\n*컨베이어\n*이송기',
        '*프레임\n*제관\n*프로파일',
      ],
      subSubcategories: {
        '가공1\n*선반,밀링*연마,연삭\n*컷팅\n*5축 가공기': [
          '*선반,밀링',
          '*연마,연삭',
          '*컷팅',
          '*5축 가공기',
        ],
        '가공2\n*절단\n*벤딩\n*절곡\n*용접': [
          '*절단',
          '*벤딩',
          '*절곡',
          '*용접',
          '기타',
        ],
        '전기 제어\n*PLC\n*PC\n*상위통신': [
          '*PLC',
          '*PC',
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
      title: '사출\n(공병, 플라스틱 등)',
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
      title: '*금형\n*3D 프린터',
      subcategories: [
        '몰드/포밍',
        '프레스 금형',
        '3D 프린터',
      ],
    ),
    CategoryModel(
      title: '공구 MALL',
      subcategories: [
        '공구 MALL',
        '전기 자재 MALL',
        '포장/케미칼 MALL',
        '볼트 MALL',
      ],
    ),
    CategoryModel(
      title: '*유공압\n*모터',
      subcategories: [
        '유공압',
        '모터',
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
      
      // 정확한 키로 조회
      return category!.subSubcategories![subcategoryTitle];
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
      
      // 정확한 키 매칭
      final hasSubSub = category.subSubcategories!.containsKey(subcategoryTitle);
      print('🔥 Exact match found: $hasSubSub');
      return hasSubSub;
    } catch (e) {
      print('🔥 Error in hasSubSubcategories: $e');
      return false;
    }
  }
}