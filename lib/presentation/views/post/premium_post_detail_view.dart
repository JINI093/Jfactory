import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../domain/entities/company_entity.dart';
import '../../viewmodels/company_viewmodel.dart';

class PremiumPostDetailView extends StatefulWidget {
  final String postId;

  const PremiumPostDetailView({
    super.key,
    required this.postId,
  });

  @override
  State<PremiumPostDetailView> createState() => _PremiumPostDetailViewState();
}

class _PremiumPostDetailViewState extends State<PremiumPostDetailView> {
  CompanyEntity? company;
  bool isLoading = true;
  String? errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }
  
  void _loadCompanyData() async {
    try {
      final companyViewModel = context.read<CompanyViewModel>();
      await companyViewModel.loadCompanyById(widget.postId);
      
      setState(() {
        company = companyViewModel.selectedCompany;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? _buildErrorState()
                : company == null
                    ? _buildNotFoundState()
                    : Column(
                        children: [
                          _buildBreadcrumb(),
                          Expanded(
                            child: SingleChildScrollView(
                              child: _buildContent(),
                            ),
                          ),
                          _buildBottomButtons(),
                        ],
                      ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => context.pop(),
      ),
      title: Image.asset(
        'assets/icons/logo2.png',
        height: 32.h,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Text(
            '제작소',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A5F),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBreadcrumb() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Text(
'${company?.category ?? ''} > ${company?.subcategory ?? ''}',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFF9800), width: 1.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildImage(),
          _buildDetailTable(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: company?.logo != null && company!.logo!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.network(
                          company!.logo!,
                          width: 48.w,
                          height: 48.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildCompanyInitial();
                          },
                        ),
                      )
                    : _buildCompanyInitial(),
              ),
              SizedBox(width: 12.w),
              Text(
                company?.companyName ?? '로딩 중...',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Icon(
            Icons.favorite,
            color: Colors.red,
            size: 28.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      height: 240.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: company?.photos.isNotEmpty == true
            ? Image.network(
                company!.photos.first,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildDetailTable() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildDetailRow('기업명', company?.companyName ?? ''),
          _buildDivider(),
          _buildDetailRow('CEO', company?.ceoName ?? ''),
          _buildDivider(),
          _buildDetailRow('카테고리', company?.category ?? ''),
          _buildDivider(),
          _buildDetailRow('서브카테고리', company?.subcategory ?? ''),
          _buildDivider(),
          _buildDetailRow('전화번호', company?.phone ?? ''),
          _buildDivider(),
          _buildDetailRow('주소', company?.address ?? ''),
          if (company?.detailAddress?.isNotEmpty == true) ...[
            _buildDivider(),
            _buildDetailRow('상세주소', company!.detailAddress!),
          ],
          if (company?.greeting?.isNotEmpty == true) ...[
            _buildDivider(),
            _buildDetailRow('인사말', company!.greeting!),
          ],
          if (company?.website?.isNotEmpty == true) ...[
            _buildDivider(),
            _buildDetailRow('웹사이트', company!.website!),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeSection() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 80.w,
                child: Text(
                  '기본사양',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildSizeItem('X', '4200'),
              _buildSizeItem('Y', '2800'),
              _buildSizeItem('Z', '1000'),
              _buildSizeItem('분할각도', '10'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSizeItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialSection() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        children: [
          _buildMaterialRow('특징', 'CNC', '수량', '2'),
        ],
      ),
    );
  }

  Widget _buildMaterialRow(String label1, String value1, String label2, String value2) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 80.w,
                child: Text(
                  label1,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value1,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 80.w,
                child: Text(
                  label2,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value2,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1.h,
      thickness: 1,
      color: Colors.grey[300],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _makePhoneCall,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF1E3A5F)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
              child: Text(
                '전화걸기',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E3A5F),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton(
              onPressed: _openWebsite,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A5F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
              child: Text(
                '회사홈페이지',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: Colors.red[400],
          ),
          SizedBox(height: 16.h),
          Text(
            '오류가 발생했습니다',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            errorMessage ?? '',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _loadCompanyData,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_outlined,
            size: 64.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            '기업을 찾을 수 없습니다',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '요청하신 기업 정보를 찾을 수 없습니다.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompanyInitial() {
    return Center(
      child: Text(
        company?.companyName.isNotEmpty == true
            ? company!.companyName[0].toUpperCase()
            : 'C',
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
  
  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[300],
      child: Icon(
        Icons.image,
        size: 60.sp,
        color: Colors.grey[500],
      ),
    );
  }
  
  void _makePhoneCall() async {
    if (company?.phone != null && company!.phone.isNotEmpty) {
      final Uri phoneUri = Uri(
        scheme: 'tel',
        path: company!.phone,
      );
      
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('전화를 걸 수 없습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _openWebsite() async {
    if (company?.website != null && company!.website!.isNotEmpty) {
      String url = company!.website!;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      
      final Uri websiteUri = Uri.parse(url);
      
      if (await canLaunchUrl(websiteUri)) {
        await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('웹사이트를 열 수 없습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}