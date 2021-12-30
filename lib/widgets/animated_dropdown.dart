
import 'package:flutter/material.dart';
import 'animated_text.dart';
import 'ring.dart';

class AnimatedDropDown extends StatefulWidget {
  AnimatedDropDown({
    Key? key,
    required this.color,
    required this.loadingColor,
    required this.onChanged,
    required this.onTap,
    required this.controller,
    required this.items,
    required this.style,
  }) : super(key: key);

  final Color color;
  final Color loadingColor;
  final Function onChanged;
  final Function onTap;

  final AnimationController controller;
  final List<String> items;
  final TextStyle style;

  @override
  State<StatefulWidget> createState() => AnimatedDropDownState();
}

class AnimatedDropDownState extends State<AnimatedDropDown>
    with SingleTickerProviderStateMixin {
  late Animation<double> _sizeAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _dropDownOpacityAnimation;
  late Animation<double> _ringThicknessAnimation;
  late Animation<double> _ringOpacityAnimation;
  late Animation<Color?> _colorAnimation;

  late Color _color;
  late Color _loadingColor;

  late List<String> items;
  bool _isLoading = false;
  bool _hover = false;
  double _width = 120.0;
  static const _height = 40.0;
  static const _loadingCircleThickness = 4.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void handleStatusChanged(status) {
    if (status == AnimationStatus.forward) {
      setState(() => _isLoading = true);
    }
    if (status == AnimationStatus.dismissed) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  void _updateColorAnimation() {


    _colorAnimation = ColorTween(
      begin: _color,
      end: _loadingColor,
    ).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.0, .65, curve: Curves.fastOutSlowIn),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedDropDown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.color != widget.color ||
        oldWidget.loadingColor != widget.loadingColor) {
      _updateColorAnimation();
    }

    if (oldWidget.items != widget.items) {
      _updateWidth();
    }
  }

  void _updateWidth() {}

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Widget _buildDropDownText(ThemeData theme, List<String> items) {
    List<DropdownMenuItem<dynamic>> dropDownItems = [];
    items.every((element) {
      dropDownItems.add(
        DropdownMenuItem(
          child: AnimatedText(
            text: element,
            style: theme.textTheme.headline4!,
          ),
        ),
      );
      return true;
    });

    return FadeTransition(
      opacity: _textOpacityAnimation,
      child: DropdownButton(
        items: dropDownItems,
        style: theme.textTheme.button,
        onChanged: (dynamic newValue) {setState(() {
        });  },
      ),
    );
  }

  Widget _buildDropDown(ThemeData theme, List<String> items) {
    final dropDownTheme = theme.floatingActionButtonTheme;

    return FadeTransition(
      opacity: _dropDownOpacityAnimation,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        child: AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) => Material(
            shape: dropDownTheme.shape,
            color: _colorAnimation.value,
            shadowColor: _color,
            elevation: !_isLoading
                ? (_hover
                    ? dropDownTheme.highlightElevation
                    : dropDownTheme.elevation)!
                : 0,
            child: child,
          ),
          child: InkWell(
            onTap: _isLoading ? widget.onTap as void Function() : null,
            splashColor: dropDownTheme.splashColor,
            customBorder: dropDownTheme.shape,
            onHighlightChanged: (value) => setState(() => _hover = value),
            child: SizeTransition(
              sizeFactor: _sizeAnimation,
              axis: Axis.horizontal,
              child: Container(
                width: _width,
                height: _height,
                alignment: Alignment.center,
                child: _buildDropDownText(theme, items),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        FadeTransition(
          opacity: _ringOpacityAnimation,
          child: AnimatedBuilder(
            animation: _ringThicknessAnimation,
            builder: (context, child) => Ring(
              color: widget.loadingColor,
              size: _height,
              thickness: _ringThicknessAnimation.value,
            ),
          ),
        ),
        if (_isLoading)
          SizedBox(
            width: _height - _loadingCircleThickness,
            height: _height - _loadingCircleThickness,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(widget.loadingColor),
              // backgroundColor: Colors.red,
              strokeWidth: _loadingCircleThickness,
            ),
          ),
        _buildDropDown(theme, widget.items),
      ],
    );
  }
}
