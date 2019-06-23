import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// This class will contain the utility methods related to drawing.
///
/// It may be method for drawing on a [Canvas], an [Image] or any other Visual elements of flutter.
///
///
/// Even though Flutter API uses SKIA API under the hood for drawings,
///  it does not expose very essential methods like,
///   ```
///   Canvas.drawText()
///   ```
/// or
///   ```
///   Paint.measureText()
///   ```
/// which are essential to many alignment and adjustment tweaks when drawing in canvas.
/// So, we need to make some work arounds for those methods.
///
///
/// For developers:
///  Make sure to add only static methods,
///  so that there is no instance dependency for the utility.
///
/// If required the dependencies can be passed as method parameters, main purpose
///  here is to keep the utility methods accessible to every class without any instance of the
///  utility class.
///
/// Dependencies:
///   PermissionManager and StorageManager utility classes for this app
///
/// Author: Harshvardhan Joshi
/// Date: 14-06-2019
///
class DrawingUtils {
  /// This method adds the watermark text in the Screenshot [image]
  ///
  /// This method uses PictureRecorder. it is not good with toImage() output,
  ///  if any other alternatives are found with improved output image quality, then
  ///  replace this approach.
  ///
  ///  In such case make sure to add detailed documentation of new approach here.
  static drawWaterMark(ui.Image image) async {
    //decide various properties based on the size of the image provided
    int imageWidth = image.width;
    int imageHeight = image.height;

    //size of watermark text
    double textSize = imageHeight * 0.03;

    //horizontal position of the watermark text
    double xPosition = imageWidth * 0.5;

    //vertical position of the watermark text
    double yPosition = imageHeight * 0.9;

    //text of watermark
    var text = "water mark";

    //Offset instance having `xPosition` and `yPosition` co-ordinates
    var positionOffset = Offset(xPosition, yPosition);

    //initialize the picture recorder to get a canvas instance
    //start recording to record the canvas changes
    var pictureRecorder = ui.PictureRecorder();

    //create a canvas instance
    var canvas = Canvas(pictureRecorder);

    //create paint instance required for drawing on canvas
    var paint = new Paint()..isAntiAlias = true;

    //draw the given unprocessed image to canvas
    canvas.drawImage(image, Offset.zero, paint);

    //draw text over canvas, which will be stored to image object in the end
    drawTextOnCanvas(canvas, text, positionOffset,
        fontSize: textSize, fontColor: Colors.blue[800]);

    //stop recording and get final output
    var pic = pictureRecorder.endRecording();

    //return the update image
    return pic.toImage(imageWidth, imageHeight);
  }

  /// This method will draw the [text] on the given [canvas]
  ///   at [positionOffset] (considering that the center of the text
  ///   is required at given position).
  /// There are also optional parameters:
  ///   - [fontSize] : double : required text size in output
  ///   - [fontColor] : Color : required text color in output
  ///   - [isBold] : bool : flag to check if bold text is required in output
  static void drawTextOnCanvas(
      ui.Canvas canvas, String text, ui.Offset positionOffset,
      {fontSize: 16.0, fontColor: Colors.black, isBold: false}) {
    //adjust the horizontal position with width of the text
    // to make sure that the text's center is at the given horizontal co-ordinate
    double adjustment = -(measureText(text) / 2);

    //get the final position to draw the text
    var finalOffset = Offset(positionOffset.dx + adjustment, positionOffset.dy);

    // get appropriate TextStyle to print the styled text in canvas
    var style = isBold
        ? TextStyle(
            color: fontColor, fontSize: fontSize, fontWeight: FontWeight.bold)
        : TextStyle(color: fontColor, fontSize: fontSize);

    // span allows to apply a text style to given text
    var span = TextSpan(style: style, text: text);

    // get text painter to draw the text on the canvas
    var textPainter = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    //call layout(), so that we can find the width of the text
    textPainter.layout();
    //draw the text at given offset position.
    textPainter.paint(canvas, finalOffset);
  }

  /// This method will measure the width of given [text]
  ///
  /// There are also optional parameters:
  ///   - [fontSize] : double : required text size to be considered in output
  ///   - [isBold] : bool : flag to check if bold text is to be considered in output
  static double measureText(String text, {fontSize: 16.0, isBold: false}) {
    // get appropriate TextStyle with given customizations
    var style = isBold
        ? TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)
        : TextStyle(fontSize: fontSize);

    // span allows to apply a text style to given text
    var span = TextSpan(style: style, text: text);

    // get text painter to draw the text on the canvas
    var textPainter = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    textPainter.layout();
    return textPainter.width;
  }
}
