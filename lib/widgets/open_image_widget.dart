import 'package:flutter/material.dart';

import '../entities/session.dart';

class OpenImageWidget extends StatefulWidget {
  final String imageId;
  final Session session;

  const OpenImageWidget(
      {Key? key, required this.imageId, required this.session})
      : super(key: key);

  @override
  State<OpenImageWidget> createState() => _OpenImageWidgetState();
}

class _OpenImageWidgetState extends State<OpenImageWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.grey,
          image: DecorationImage(
            image: NetworkImage(
              widget.session.domainName + "/api/postImages/" + widget.imageId,
              headers: widget.session.headers,
            ),
            fit: BoxFit.contain,
          ),
        ),
      ),
    ));
  }
}
