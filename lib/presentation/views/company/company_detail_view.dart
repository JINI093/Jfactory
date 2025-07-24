import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/company_viewmodel.dart';

class CompanyDetailView extends StatefulWidget {
  final String companyId;

  const CompanyDetailView({
    super.key,
    required this.companyId,
  });

  @override
  State<CompanyDetailView> createState() => _CompanyDetailViewState();
}

class _CompanyDetailViewState extends State<CompanyDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyViewModel>().loadCompany(widget.companyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Company Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          Consumer<CompanyViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.selectedCompany == null) return const SizedBox();
              
              return IconButton(
                icon: Icon(
                  viewModel.selectedCompany!['isFavorite'] 
                      ? Icons.favorite 
                      : Icons.favorite_border,
                  color: viewModel.selectedCompany!['isFavorite'] 
                      ? Colors.red 
                      : null,
                ),
                onPressed: viewModel.toggleFavorite,
              );
            },
          ),
        ],
      ),
      body: Consumer<CompanyViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(viewModel.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadCompany(widget.companyId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final company = viewModel.selectedCompany;
          if (company == null) {
            return const Center(child: Text('Company not found'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Image
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    image: company['imageUrl'] != null
                        ? DecorationImage(
                            image: NetworkImage(company['imageUrl']),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: company['imageUrl'] == null
                      ? const Center(
                          child: Icon(
                            Icons.business,
                            size: 80,
                            color: Colors.grey,
                          ),
                        )
                      : null,
                ),
                
                // Company Info
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company['name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.category, size: 20, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            company['category'],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.location_on, size: 20, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            company['location'],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Equipment Details
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Equipment Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildEquipmentCard(company),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Contact Button
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Handle contact action
                      },
                      icon: const Icon(Icons.message),
                      label: const Text('Contact Company'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEquipmentCard(Map<String, dynamic> company) {
    final specs = company['specifications'] as Map<String, dynamic>;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            company['equipment'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${company['manufacturer']} - ${company['model']}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Specifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildSpecRow('Axis', 'X: ${specs['x']}, Y: ${specs['y']}, Z: ${specs['z']}'),
          _buildSpecRow('Angle', '${specs['angle']}°'),
          _buildSpecRow('Table Size', specs['tableSize']),
          _buildSpecRow('Features', specs['features']),
          _buildSpecRow('Quantity', specs['quantity']),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}