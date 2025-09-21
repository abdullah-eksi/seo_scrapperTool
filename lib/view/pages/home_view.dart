import 'package:flutter/material.dart';
import 'package:flutter_scrapper/controller/home_controller.dart';
import 'package:flutter_scrapper/view/components.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _controller = HomeController();
  final TextEditingController _urlController = TextEditingController(
    text: 'https://abdullaheksi.tr',
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: HomeAppBarComponent(
        isLoading: _controller.isLoading,
        onClearData: _controller.clearData,
        screenSize: size,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFF), Color(0xFFFFFFFF), Color(0xFFF3F7FF)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              final isTablet =
                  constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
              final isDesktop = constraints.maxWidth >= 1200;

              double horizontalPadding;
              double verticalPadding;

              if (isMobile) {
                horizontalPadding = 12.0;
                verticalPadding = 16.0;
              } else if (isTablet) {
                horizontalPadding = 24.0;
                verticalPadding = 20.0;
              } else {
                horizontalPadding = 32.0;
                verticalPadding = 24.0;
              }

              return SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: isDesktop ? 800 : double.infinity,
                          ),
                          child: UrlInputComponent(
                            controller: _urlController,
                            isLoading: _controller.isLoading,
                            onFetchData: () =>
                                _controller.fetchData(_urlController.text),
                            onClear: () {
                              _urlController.clear();
                              _controller.clearData();
                            },
                          ),
                        ),
                        SizedBox(height: isMobile ? 16 : 24),

                        Container(
                          constraints: BoxConstraints(
                            maxWidth: isDesktop ? 800 : double.infinity,
                          ),
                          child: StatusIndicatorComponent(
                            isLoading: _controller.isLoading,
                            errorMessage: _controller.errorMessage,
                            pageTitle: _controller.pageTitle,
                            onClearError: _controller.clearError,
                          ),
                        ),
                        SizedBox(height: isMobile ? 16 : 24),

                        if (_controller.paragraphs.isNotEmpty ||
                            _controller.links.isNotEmpty ||
                            _controller.images.isNotEmpty)
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: isDesktop ? 800 : double.infinity,
                            ),
                            child: StatisticsSectionComponent(
                              isMobile: isMobile,
                              isTablet: isTablet,
                              paragraphCount: _controller.paragraphs.length,
                              linkCount: _controller.links.length,
                              imageCount: _controller.images.length,
                              headingCount: _controller.headings.length,
                              schemaCount: _controller.schemaData.length,
                            ),
                          ),

                        SizedBox(height: isMobile ? 16 : 24),

                        Container(
                          height: constraints.maxHeight * 0.6,
                          constraints: BoxConstraints(
                            minHeight: 400,
                            maxHeight: 800,
                            maxWidth: isDesktop ? 1200 : double.infinity,
                          ),
                          child: CustomTabBarComponent(
                            tabs: [
                              TabData(
                                title: isMobile ? 'Paragraf' : 'Paragraflar',
                                icon: Icons.format_align_left_outlined,
                                count: _controller.paragraphs.length,
                              ),
                              TabData(
                                title: isMobile ? 'Başlık' : 'Başlıklar',
                                icon: Icons.title_outlined,
                                count: _controller.headings.length,
                              ),
                              TabData(
                                title: isMobile ? 'Link' : 'Bağlantılar',
                                icon: Icons.link_outlined,
                                count: _controller.links.length,
                              ),
                              TabData(
                                title: isMobile ? 'Resim' : 'Görseller',
                                icon: Icons.photo_library_outlined,
                                count: _controller.images.length,
                              ),
                              TabData(
                                title: isMobile ? 'SEO' : 'SEO Raporu',
                                icon: Icons.analytics_outlined,
                                count: _controller.seoInfo.length,
                              ),
                              TabData(
                                title: isMobile ? 'Meta' : 'Meta Tags',
                                icon: Icons.tag_outlined,
                                count: _controller.metaTags.length,
                              ),
                              TabData(
                                title: isMobile
                                    ? 'Zengin İçerik'
                                    : 'Schema.org',
                                icon: Icons.code_outlined,
                                count: _controller.schemaData.length,
                              ),
                              TabData(
                                title: isMobile ? 'Form' : 'Form Analizi',
                                icon: Icons.web_asset_outlined,
                                count: _controller.realFormCount,
                              ),
                            ],
                            tabViews: [
                              ParagraphListComponent(
                                paragraphs: _controller.paragraphs,
                              ),
                              HeadingsComponent(headings: _controller.headings),
                              LinkListComponent(
                                links: _controller.links,
                                onLinkTap: (link) =>
                                    LinkDetailDialogComponent.show(
                                      context,
                                      link,
                                    ),
                                currentDomain: _controller.currentDomain,
                              ),
                              ImageGridComponent(images: _controller.images),
                              SeoInfoComponent(seoInfo: _controller.seoInfo),
                              MetaTagsComponent(metaTags: _controller.metaTags),
                              SchemaComponent(
                                schemaData: _controller.schemaData,
                              ),
                              FormAnalysisComponent(
                                formElements: _controller.formElements,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: verticalPadding),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
