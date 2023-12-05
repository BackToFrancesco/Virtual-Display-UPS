import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../blocs/ups_connection_handler_bloc/ups_connection_handler_bloc.dart';
import '../../config/colors.dart' as app_colors;
import '../../repositories/modbus_data_repository/models/modbus/ups_info.dart';
import '../../utils/shared_preferences_global.dart'
    as shared_preferences_global;
import '../../utils/translator.dart';
import '../../widgets/custom_text/custom_text.dart';

abstract class Dialog {
  AlertDialog createDialog(BuildContext context, String? title,
      String? description, VoidCallback? onButtonClicked);
}

class InfoDialog extends Dialog {
  @override
  AlertDialog createDialog(BuildContext context, String? title,
      String? description, VoidCallback? onButtonClicked) {
    return AlertDialog(
      title: Row(
        children: <Widget>[
          Icon(Icons.info,
              color: app_colors.socomecBlueLight,
              size: (SizerUtil.deviceType == DeviceType.mobile ? null : 4.0.w)),
          const SizedBox(
            width: 10,
          ),
          Expanded(child: CustomText(title ?? "", 12.0.sp, 12.0.sp))
        ],
      ),
      content: CustomText(description ?? "", 9.0.sp, 9.0.sp),
      actionsPadding: const EdgeInsets.only(right: 8.0),
      actions: <Widget>[
        ElevatedButton(
            style: ElevatedButton.styleFrom(primary: app_colors.socomecBlue),
            onPressed: () {
              if (onButtonClicked != null) {
                onButtonClicked();
              } else {
                Navigator.pop(context);
              }
            },
            child: CustomText('Ok', 9.0.sp, 9.0.sp, color: app_colors.white))
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class ErrorDialog extends Dialog {
  @override
  AlertDialog createDialog(BuildContext context, String? title,
      String? description, VoidCallback? onButtonClicked) {
    return AlertDialog(
      title: Row(
        children: <Widget>[
          Icon(Icons.error,
              color: app_colors.red,
              size: (SizerUtil.deviceType == DeviceType.mobile ? null : 4.0.w)),
          const SizedBox(
            width: 10,
          ),
          Expanded(child: CustomText(title ?? "", 12.0.sp, 12.0.sp))
        ],
      ),
      content: CustomText(description ?? "", 9.0.sp, 9.0.sp),
      actionsPadding: const EdgeInsets.only(right: 8.0),
      actions: <Widget>[
        ElevatedButton(
            style: ElevatedButton.styleFrom(primary: app_colors.socomecBlue),
            onPressed: () {
              if (onButtonClicked != null) {
                onButtonClicked();
              } else {
                Navigator.pop(context);
              }
            },
            child: CustomText("Ok", 9.0.sp, 9.0.sp, color: app_colors.white)),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class ConfirmationDialog extends Dialog {
  @override
  AlertDialog createDialog(BuildContext context, String? title,
      String? description, VoidCallback? onButtonClicked) {
    return AlertDialog(
      title: Row(
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.arrow_back,
                  color: app_colors.black,
                  size: (SizerUtil.deviceType == DeviceType.mobile
                      ? null
                      : 2.0.h)),
              onPressed: () {
                Navigator.pop(context);
              }),
          const SizedBox(
            width: 10,
          ),
          Expanded(child: CustomText(title ?? "", 12.0.sp, 12.0.sp)),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(25, 5, 25, 10),
      content: SizedBox(
          width: 70.0.w,
          height: 8.0.h,
          child: CustomText(description ?? "", 9.0.sp, 9.0.sp)),
      actionsPadding: const EdgeInsets.only(right: 8.0),
      actions: <Widget>[
        ElevatedButton(
            style: ElevatedButton.styleFrom(primary: app_colors.lightRed),
            onPressed: () {
              Navigator.pop(context);
            },
            child:
                CustomText("Cancel", 9.0.sp, 9.0.sp, color: app_colors.white)),
        ElevatedButton(
            style: ElevatedButton.styleFrom(primary: app_colors.socomecBlue),
            onPressed: onButtonClicked,
            child: CustomText("Yes", 9.0.sp, 9.0.sp, color: app_colors.white)),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class WaitingForTechnicianDialog extends Dialog {
  @override
  AlertDialog createDialog(BuildContext context, String? title,
      String? description, VoidCallback? onButtonClicked) {
    return AlertDialog(
      title: Row(
        children: <Widget>[
          Icon(Icons.people_alt_outlined,
              color: app_colors.black,
              size: (SizerUtil.deviceType == DeviceType.mobile ? null : 5.0.w)),
          const SizedBox(
            width: 10,
          ),
          Expanded(child: CustomText(title ?? "", 12.0.sp, 12.0.sp))
        ],
      ),
      content: CustomText(description ?? "", 9.0.sp, 9.0.sp),
      actionsPadding: const EdgeInsets.only(right: 8.0),
      actions: <Widget>[
        ElevatedButton(
            style: ElevatedButton.styleFrom(primary: app_colors.red),
            onPressed: () {
              if (onButtonClicked != null) {
                onButtonClicked();
              } else {
                Navigator.pop(context);
              }
            },
            child: CustomText("Delete request", 9.0.sp, 9.0.sp,
                color: app_colors.white)),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class UpsInfoDialog extends Dialog {
  final Translator _translator = Translator();

  @override
  AlertDialog createDialog(BuildContext context, String? title,
      String? description, VoidCallback? onButtonClicked) {
    final UpsInfo upsInfo = context.read<UpsConnectionHandlerBloc>().upsInfo;
    return AlertDialog(
      title: Row(
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.arrow_back,
                  color: app_colors.black,
                  size: (SizerUtil.deviceType == DeviceType.mobile
                      ? null
                      : 2.0.h)),
              onPressed: () {
                Navigator.pop(context);
              }),
          const SizedBox(
            width: 10,
          ),
          Expanded(
              child: CustomText(
                  _translator.translateIfExists('UPS'), 14.0.sp, 1.8.h))
        ],
      ),
      content: SizedBox(
          width: 25.0.w,
          height: 13.0.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                  _translator.translateIfExists("IP_ADDRESS") +
                      ": " +
                      upsInfo.ipAddress,
                  13.0.sp,
                  1.5.h),
              const SizedBox(height: 5),
              CustomText(
                  _translator.translateIfExists("PORT") +
                      ": " +
                      upsInfo.port.toString(),
                  13.0.sp,
                  1.5.h),
              const SizedBox(height: 5),
              CustomText(
                  _translator.translateIfExists("SLAVE_NUMBER") +
                      ": " +
                      upsInfo.slaveId.toString(),
                  13.0.sp,
                  1.5.h),
            ],
          )),
      actionsPadding: const EdgeInsets.only(right: 8.0),
      actions: <Widget>[
        ElevatedButton(
            style: ElevatedButton.styleFrom(primary: app_colors.socomecBlue),
            onPressed: () {
              Navigator.pop(context);
            },
            child:
                CustomText("Close", 9.0.sp, 9.0.sp, color: app_colors.white)),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class LanguageSelectionDialog extends Dialog {
  final Translator _translator = Translator();

  @override
  AlertDialog createDialog(BuildContext context, String? title,
      String? description, VoidCallback? onButtonClicked) {
    return AlertDialog(
      scrollable: true,
      title: Row(
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.arrow_back,
                  color: app_colors.black,
                  size: (SizerUtil.deviceType == DeviceType.mobile
                      ? null
                      : 2.0.h)),
              onPressed: () {
                Navigator.pop(context);
              }),
          const SizedBox(
            width: 10,
          ),
          Expanded(
              child: CustomText(
                  _translator.translateIfExists('Language'), 14.0.sp, 1.8.h))
        ],
      ),
      content: SizedBox(
        width: 45.0.w,
        height: 45.0.h,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _translator.getLanguages().length,
          itemBuilder: (BuildContext context, int index) {
            return Material(
                color: app_colors.white,
                child: ListTile(
                  title: CustomText(
                      _translator.getLanguages()[index], null, 1.5.h),
                  tileColor: index ==
                          _translator
                              .getLanguages()
                              .indexOf(_translator.targetLanguage)
                      ? app_colors.lightBlue
                      : null,
                  onTap: () {
                    Navigator.pop(context, index);
                  },
                ));
          },
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class RecentUpsConnectionsDialog extends Dialog {
  final Translator _translator = Translator();

  @override
  AlertDialog createDialog(BuildContext context, String? title,
      String? description, VoidCallback? onButtonClicked) {
    final SharedPreferences prefs = shared_preferences_global.sharedPreferences;
    final List<String> recentConnections =
        prefs.getStringList("recentConnections") ?? [];

    return AlertDialog(
        scrollable: true,
        title: Row(
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.arrow_back,
                    color: app_colors.black,
                    size: (SizerUtil.deviceType == DeviceType.mobile
                        ? null
                        : 2.0.h)),
                onPressed: () {
                  Navigator.pop(context);
                }),
            const SizedBox(
              width: 10,
            ),
            Expanded(
                child: CustomText(
                    _translator.translateIfExists('Recent connections'),
                    14.0.sp,
                    1.8.h)),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 30.0.h,
            maxWidth: 30.0.h,
            minHeight: 25.0.w,
          ),
          child: recentConnections.isNotEmpty
              ? SizedBox(
                  width: 30.0.h,
                  height: 45.0.h,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: recentConnections.length,
                      itemBuilder: (BuildContext context, int index) => Card(
                          elevation: 3,
                          child: ListTile(
                              contentPadding: SizerUtil.deviceType ==
                                      DeviceType.mobile
                                  ? null
                                  : const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                      _translator
                                              .translateIfExists("IP_ADDRESS") +
                                          ": " +
                                          prefs.getStringList(
                                              recentConnections[index])![0],
                                      10.5.sp,
                                      1.3.h),
                                  CustomText(
                                      _translator.translateIfExists("PORT") +
                                          ": " +
                                          prefs.getStringList(
                                              recentConnections[index])![1],
                                      10.5.sp,
                                      1.3.h),
                                  CustomText(
                                      _translator.translateIfExists(
                                              "SLAVE_NUMBER") +
                                          ": " +
                                          prefs.getStringList(
                                              recentConnections[index])![2],
                                      10.5.sp,
                                      1.3.h)
                                ],
                              ),
                              trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 5, 10, 5),
                                      primary: app_colors.socomecBlue),
                                  onPressed: () {
                                    Navigator.pop(context, index);
                                  },
                                  child: CustomText(
                                      _translator.translateIfExists('Connect'),
                                      10.0.sp,
                                      1.3.h,
                                      color: app_colors.white))))))
              : Center(
                  child: CustomText('No recent connections', 11.0.sp, 1.5.h)),
        ));
  }
}
