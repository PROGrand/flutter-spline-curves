import 'package:flutter/material.dart';
import 'package:flutter_spline_curves/flutter_spline_curves/curve_preview.dart';
import 'package:flutter_spline_curves/flutter_spline_curves/function_curve.dart';
import 'package:flutter_spline_curves/flutter_spline_curves/functions/catmull_rom_fabric.dart';
import 'package:flutter_spline_curves/flutter_spline_curves/curve_editor.dart';
import 'package:flutter_spline_curves/flutter_spline_curves/functions/integrated_inverted_function_fabric.dart';
import 'package:flutter_spline_curves/flutter_spline_curves/functions/interpolated_function.dart';
import 'package:flutter_spline_curves/flutter_spline_curves/functions/interpolated_function_base.dart';
import 'package:flutter_spline_curves/flutter_spline_curves/point2d.dart';
import 'package:flutter_spline_curves/flutter_spline_curves/progress_curve_holder.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  _MyHomePageState() {

    var startPoint = Point2D(0, 0.5);
    var endPoint = Point2D(1, 0.5);

    points = [
      startPoint,
      Point2D(0.1, 0.1),
      Point2D(0.3, 0.9),
      endPoint
    ];
    function = CatmullRomSplineFunction(points, monotonic: true, clamped: true);

    ProgressCurveHolder holder = ProgressCurveHolder(function,
        progressFunction: IntegratedInvertedFunction(
              CatmullRomSplinePointFabric(),
            points: points,
            monotonic: true,
            clamped: true));

    curveEditor = CurveEditor(
        points: points,
        curveHolder: holder,
        fixedPoints: [startPoint, endPoint]);

    curve = FunctionCurve(holder.progressFunction);

    curvePreview = FunctionPreview(function: holder.progressFunction);
  }

  List<Point2D> points;
  InterpolatedFunction function;
  CurveEditor curveEditor;
  FunctionPreview curvePreview;
  FunctionCurve curve;
  AnimationController _targetController;
  Animation<double> _targetAnimation;

  @override
  void initState() {
    super.initState();
    _targetController =
        AnimationController(duration: Duration(seconds: 20), vsync: this);

    _targetAnimation = CurvedAnimation(
        parent: _targetController,
        curve: curve,
        reverseCurve: Curves.easeInOutSine)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        switch (status) {
          case AnimationStatus.completed:
            startAnimation();
            break;
          default:
        }
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      startAnimation();
    });
  }

  @override
  void dispose() {
    _targetController.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(children: [
        Padding(padding: EdgeInsets.all(8), child: Text('Animation')),
        Container(
          height: 48,
          child: LinearProgressIndicator(
            value: _targetAnimation.value,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
        Expanded(
            child: Container(
          color: Colors.black12,
          child: curveEditor,
        )),
        Expanded(
            child: Container(
          color: Colors.white,
          child: curvePreview,
        ))
      ]),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.details),
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                // get points from curveEditor
                List<Point2D> points = curveEditor.points;

                // get y values
                String yValues = '';
                for (int i = 0; i < 20; i++) {
                  yValues += '${function.value(i * 0.05).toString()}, ';
                }

                return AlertDialog(
                  title: Text('Spline y values'),
                  content: Text(yValues),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Close'),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                );
              });
        },
      ),
    );
  }

  void startAnimation() {
    _targetController.reset();
    _targetController.duration = Duration(seconds: 20);
    _targetController.animateTo(1.0);
  }
}
