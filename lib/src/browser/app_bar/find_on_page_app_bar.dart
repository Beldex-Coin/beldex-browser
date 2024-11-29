// import 'package:beldex_browser/src/browser/models/browser_model.dart';
// import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class FindOnPageAppBar extends StatefulWidget {
//   final void Function()? hideFindOnPage;

//   const FindOnPageAppBar({Key? key, this.hideFindOnPage}) : super(key: key);

//   @override
//   State<FindOnPageAppBar> createState() => _FindOnPageAppBarState();
// }

// class _FindOnPageAppBarState extends State<FindOnPageAppBar> {
//   final TextEditingController _finOnPageController = TextEditingController();

//   OutlineInputBorder outlineBorder = const OutlineInputBorder(
//     borderSide: BorderSide(color: Colors.transparent, width: 0.0),
//     borderRadius: BorderRadius.all(
//       Radius.circular(50.0),
//     ),
//   );

//   @override
//   void dispose() {
//     _finOnPageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var browserModel = Provider.of<BrowserModel>(context, listen: false);
//     var webViewModel = browserModel.getCurrentTab()?.webViewModel;
//     var findInteractionController = webViewModel?.findInteractionController;
//     final themeProvider = Provider.of<DarkThemeProvider>(context,listen: false);

//     return PreferredSize(
//              preferredSize: Size.fromHeight(90),
//         child: Container(
//           height: 45,
//           width: double.infinity,
//           margin: EdgeInsets.only(top: 40, left: 15, right: 15, bottom: 8),
//           decoration: BoxDecoration(
//               color: themeProvider.darkTheme
//                   ? Color(0xff282836)
//                   : Color(0xffF3F3F3),
//               borderRadius: BorderRadius.circular(8)),
//               child: LayoutBuilder(
//                 builder: (context, constraint) {
//                   return Row(
//                     children: [
//                      Container(
//                       width: constraint.maxWidth/1.6,
//                       //color: Colors.yellow,
//                       child: TextField(
//             onSubmitted: (value) {
//               findInteractionController?.findAll(find: value);
//             },
//             controller: _finOnPageController,
//             textInputAction: TextInputAction.go,
//             decoration: InputDecoration(
//               contentPadding: const EdgeInsets.all(10.0),
//               filled: true,
//               fillColor: Colors.transparent,
//               border: InputBorder.none,
//               // focusedBorder: outlineBorder,
//               // enabledBorder: outlineBorder,
//               hintText: "Find on page ...",
//               hintStyle:Theme.of(context)
//                           .textTheme
//                           .bodyMedium, // const TextStyle( fontSize: 14.0,fontWeight: FontWeight.normal),
//             ),
//             style:Theme.of(context)
//                           .textTheme
//                           .bodyMedium,// const TextStyle( fontSize: 14.0),
//           ),
//                      ),
//                      Container(
//                       width: constraint.maxWidth/2.7,
//                       //color: Colors.green,
//                       child: LayoutBuilder(
//                         builder: (context, constraint) {
//                           return Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                                    SizedBox(
//                                     width: constraint.maxWidth/4.1,
//                                      child: IconButton(
//                                       icon: const Icon(Icons.keyboard_arrow_up),
//                                       onPressed: () {
//                                         findInteractionController?.findNext(forward: false);
//                                       },
//                                     ),
//                                    ),
//                                   SizedBox(
//                                     //color: Colors.yellow,
//                                   width: constraint.maxWidth/3.7,
//                                     child: IconButton(
//                                       icon: const Icon(Icons.keyboard_arrow_down),
//                                       onPressed: () {
//                                         findInteractionController?.findNext(forward: true);
//                                       },
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     //color: Colors.blue,
//                                     width: constraint.maxWidth/2.1,
//                                     child: IconButton(
//                                       icon: const Icon(Icons.close),
//                                       onPressed: () {
//                                         findInteractionController?.clearMatches();
//                                         _finOnPageController.text = "";
                                                              
//                                         if (widget.hideFindOnPage != null) {
//                                           widget.hideFindOnPage!();
//                                         }
//                                       },
//                                     ),
//                                   ),
//                             ],
//                           );
//                         }
//                       ),
//                      )
                      
                      
//                     ],
//                   );
//                 }
//               ),
//         )
//        );
    
//     // PreferredSize(
//     // preferredSize:Size.fromHeight(90),
//     //  child:Container(
//     //     height:45,
//     //       width: double.infinity,
//     //       margin: EdgeInsets.only(top: 40,left:15,right:15,bottom: 8),
//     //       padding: EdgeInsets.only(right:10),
//     //       decoration: BoxDecoration(
//     //         color: themeProvider.darkTheme
//     //               ? Color(0xff282836)
//     //               : Color(0xffF3F3F3), // Color(0xff282836),
//     //         borderRadius: BorderRadius.circular(8)
//     //       ),
//     //       child: 
//     //       Row(
//     //         children:[
//     //           Expanded(
//     //             flex: 2,
//     //             child:TextField(
//     //         onSubmitted: (value) {
//     //           findInteractionController?.findAll(find: value);
//     //         },
//     //         controller: _finOnPageController,
//     //         textInputAction: TextInputAction.go,
//     //         decoration: InputDecoration(
//     //           contentPadding: const EdgeInsets.all(10.0),
//     //           filled: true,
//     //           fillColor: Colors.transparent,
//     //           border: InputBorder.none,
//     //           // focusedBorder: outlineBorder,
//     //           // enabledBorder: outlineBorder,
//     //           hintText: "Find on page ...",
//     //           hintStyle:Theme.of(context)
//     //                       .textTheme
//     //                       .bodyMedium, // const TextStyle( fontSize: 14.0,fontWeight: FontWeight.normal),
//     //         ),
//     //         style:Theme.of(context)
//     //                       .textTheme
//     //                       .bodyMedium,// const TextStyle( fontSize: 14.0),
//     //       )
//     //              ),
//     //           Expanded(
//     //             flex: 1,
//     //             child: Container(
//     //               //color: Colors.white,
//     //               child: Row(
//     //                 children: [
//     //                    SizedBox(
//     //                     width: 25,
//     //                      child: IconButton(
//     //                                icon: const Icon(Icons.keyboard_arrow_up),
//     //                                onPressed: () {
//     //                                  findInteractionController?.findNext(forward: false);
//     //                                },
//     //                              ),
//     //                    ),
//     //     Padding(
//     //       padding: const EdgeInsets.symmetric(horizontal:8.0),
//     //       child: SizedBox(
//     //         width: 25,
//     //         child: IconButton(
//     //           color:themeProvider.darkTheme ? Colors.white : Colors.black,
//     //           icon: const Icon(Icons.keyboard_arrow_down),
//     //           onPressed: () {
//     //             findInteractionController?.findNext(forward: true);
//     //           },
//     //         ),
//     //       ),
//     //     ),
//     //     SizedBox(
//     //       width: 25,
//     //       child: IconButton(
//     //         color: themeProvider.darkTheme ? Colors.white : Colors.black,
//     //         focusColor: Colors.transparent,
//     //         icon: const Icon(Icons.close,size:20),
//     //         onPressed: () {
//     //           findInteractionController?.clearMatches();
//     //           _finOnPageController.text = "";
          
//     //           if (widget.hideFindOnPage != null) {
//     //             widget.hideFindOnPage!();
//     //           }
//     //         },
//     //       ),
//     //     ),
//     //                 ],
//     //               ),
//     //             )
//     //           )
//     //         ]
//     //       ),
//     //  )
//     //  );



//     // AppBar(
//     //   titleSpacing: 10.0,
//     //   title: SizedBox(
//     //       height: 40.0,
//     //       child: TextField(
//     //         onSubmitted: (value) {
//     //           findInteractionController?.findAll(find: value);
//     //         },
//     //         controller: _finOnPageController,
//     //         textInputAction: TextInputAction.go,
//     //         decoration: InputDecoration(
//     //           contentPadding: const EdgeInsets.all(10.0),
//     //           filled: true,
//     //           fillColor: Colors.white,
//     //           border: outlineBorder,
//     //           focusedBorder: outlineBorder,
//     //           enabledBorder: outlineBorder,
//     //           hintText: "Find on page ...",
//     //           hintStyle: const TextStyle(color: Colors.black54, fontSize: 16.0),
//     //         ),
//     //         style: const TextStyle(color: Colors.black, fontSize: 16.0),
//     //       )),
//     //   actions: <Widget>[
//     //     IconButton(
//     //       icon: const Icon(Icons.keyboard_arrow_up),
//     //       onPressed: () {
//     //         findInteractionController?.findNext(forward: false);
//     //       },
//     //     ),
//     //     IconButton(
//     //       icon: const Icon(Icons.keyboard_arrow_down),
//     //       onPressed: () {
//     //         findInteractionController?.findNext(forward: true);
//     //       },
//     //     ),
//     //     IconButton(
//     //       icon: const Icon(Icons.close),
//     //       onPressed: () {
//     //         findInteractionController?.clearMatches();
//     //         _finOnPageController.text = "";

//     //         if (widget.hideFindOnPage != null) {
//     //           widget.hideFindOnPage!();
//     //         }
//     //       },
//     //     ),
//     //   ],
//     // );
//   }

// }
