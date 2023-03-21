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
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            Positioned(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.95),
                  image: DecorationImage(
                    image: NetworkImage(
                      widget.session.domainName +
                          "/api/postImages/" +
                          widget.imageId,
                      headers: widget.session.headers,
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              left: 0,
              top: 0,
            ),
            Positioned(
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
              left: 0,
              top: 0,
            ),
          ],
        ),
      ),
    );
  }
}
