enum OnboardingPetalOrientation {
  topRight,
  topLeft,
  bottomRight,
  bottomLeft,
  diagonalTopLeft,
  diagonalTopRight;
}

class OnboardingPetalShape {
  final OnboardingPetalOrientation petalStyle;

  OnboardingPetalShape({this.petalStyle = OnboardingPetalOrientation.topRight});

  String get zero => "0px";
  String get full => "100%";

  String get topLeftRadius {
    switch (petalStyle) {
      case OnboardingPetalOrientation.topLeft:
      case OnboardingPetalOrientation.diagonalTopLeft:
        return zero;
      case OnboardingPetalOrientation.topRight:
      case OnboardingPetalOrientation.bottomRight:
      case OnboardingPetalOrientation.bottomLeft:
      case OnboardingPetalOrientation.diagonalTopRight:
        return full;
    }
  }

  String get topRightRadius {
    switch (petalStyle) {
      case OnboardingPetalOrientation.topRight:
      case OnboardingPetalOrientation.diagonalTopRight:
        return zero;
      case OnboardingPetalOrientation.topLeft:
      case OnboardingPetalOrientation.bottomRight:
      case OnboardingPetalOrientation.bottomLeft:
      case OnboardingPetalOrientation.diagonalTopLeft:
        return full;
    }
  }

  String get bottomLeftRadius {
    switch (petalStyle) {
      case OnboardingPetalOrientation.bottomLeft:
      case OnboardingPetalOrientation.diagonalTopRight:
        return zero;
      case OnboardingPetalOrientation.topRight:
      case OnboardingPetalOrientation.topLeft:
      case OnboardingPetalOrientation.bottomRight:
      case OnboardingPetalOrientation.diagonalTopLeft:
        return full;
    }
  }

  String get bottomRightRadius {
    switch (petalStyle) {
      case OnboardingPetalOrientation.bottomRight:
      case OnboardingPetalOrientation.diagonalTopLeft:
        return zero;
      case OnboardingPetalOrientation.topRight:
      case OnboardingPetalOrientation.topLeft:
      case OnboardingPetalOrientation.bottomLeft:
      case OnboardingPetalOrientation.diagonalTopRight:
        return full;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "type": "RoundedRectangle",
      "borderRadius": {
        "topLeft": {
          "x": topLeftRadius,
          "y": topLeftRadius,
        },
        "topRight": {
          "x": topRightRadius,
          "y": topRightRadius,
        },
        "bottomLeft": {
          "x": bottomLeftRadius,
          "y": bottomLeftRadius,
        },
        "bottomRight": {
          "x": bottomRightRadius,
          "y": bottomRightRadius,
        },
      },
      "borderSides": {
        "top": {
          "color": "ff000000",
          "width": 0,
          "style": "none",
          "strokeCap": "butt",
          "strokeJoin": "miter",
        },
        "bottom": {
          "color": "ff000000",
          "width": 0,
          "style": "none",
          "strokeCap": "butt",
          "strokeJoin": "miter",
        },
        "left": {
          "color": "ff000000",
          "width": 0,
          "style": "none",
          "strokeCap": "butt",
          "strokeJoin": "miter",
        },
        "right": {
          "color": "ff000000",
          "width": 0,
          "style": "none",
          "strokeCap": "butt",
          "strokeJoin": "miter",
        },
      },
    };
  }
}
