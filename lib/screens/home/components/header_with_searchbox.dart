import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plant_app/constant.dart';
import 'package:plant_app/bloc/camera_bloc.dart';

class HeaderWithSearchBox extends StatelessWidget {
  const HeaderWithSearchBox({
    super.key,
    required this.size,
  });

  final Size size;

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Ambil Foto'),
            onTap: () {
              Navigator.pop(ctx);
              final bloc = context.read<CameraBloc>();
              if (bloc.state is! CameraReady) {
                bloc.add(InitializeCamera());
              }
              bloc.add(OpenCameraAndCapture(context));
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Pilih dari Galeri'),
            onTap: () {
              Navigator.pop(ctx);
              context.read<CameraBloc>().add(PickImageFromGallery());
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CameraBloc, CameraState>(
      listener: (context, state) {
        if (state is CameraReady && state.snackbarMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.snackbarMessage!)),
          );
          context.read<CameraBloc>().add(ClearSnackbar());
        }
      },
      builder: (context, state) {
        return Container(
          margin: EdgeInsets.only(bottom: kDefaultPadding * 2.5),
          height: size.height * 0.2,
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.only(
                  left: kDefaultPadding,
                  right: kDefaultPadding,
                  bottom: 36 + kDefaultPadding,
                ),
                height: size.height * 0.2 - 27,
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Hi Isro!',
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () => _showImageSourceSheet(context),
                      child: BlocBuilder<CameraBloc, CameraState>(
                        builder: (context, state) {
                          if (state is CameraReady && state.imageFile != null) {
                            return CircleAvatar(
                              radius: 24,
                              backgroundImage: FileImage(state.imageFile!),
                            );
                          } else {
                            return const CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person, color: Colors.grey),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: kDefaultPadding),
                  padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                    offset: Offset(0, 10),
                        blurRadius: 50,
                        color: kPrimaryColor.withAlpha(80)
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {},
                          decoration: InputDecoration(
                            hintText: "Search",
                            hintStyle: TextStyle(
                          color: kPrimaryColor.withAlpha(80)
                            ),
                            enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none
                          ),
                        ),
                      ),
                      SvgPicture.asset('assets/icons/search.svg'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
