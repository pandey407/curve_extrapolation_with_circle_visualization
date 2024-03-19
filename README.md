# Curve Extrapolation and Visualization Task

## Problem Statement
Develop a Flutter application with the objective of enabling users to manipulate the positions of five draggable points labeled as 1, 2, 3, 4, and 5 on the screen. The application should generate a smooth curve connecting these five points seamlessly. Additionally, the application should feature a ball with a diameter of 20 pixels on this newly generated screen. The task involves programming the application to extrapolate the movement of this ball along the drawn curve.

## Task Breakdown

1. **Set Up Flutter Project:**
   - Create a new Flutter project.
   - Set up necessary dependencies for drag-and-reposition, handling gestures on custom painters using [touchable](https://pub.dev/packages/touchable).

2. **Implement Drag-and-Reposition Functionality:**
   - Create draggable custom paint objects for each point (1, 2, 3, 4, and 5).
   - Implement logic to handle dragging and repositioning of these widgets.

3. **Draw Smooth Curve:**
   - Utilize cubic Bézier splines to create a smooth curve that connects the five points.
   - Implement algorithms or libraries that calculate the control points for the cubic Bézier curves based on the positions of the draggable points.

4. **Extrapolate Proof Ball Movement:**
   - Calculate the points on the curve using the PathMetric of the path.
   - Implement logic to extrapolate the movement of the proof ball along the drawn curve with a Tween Animation from 0 to 1, representing the progress of the ball along the drawn curve.
   - Track the positions of the proof ball for fitting them on the curve.
   - Develop logic to calculate non-overlapping positions for the balls along the drawn curve.
   
   The mathematical insights related to the cubic Bézier spline function, its derivatives, and boundary conditions have been provided in a PDF document. You can access it [here](./ashlesh_curve_interpolation_visualization_impl.pdf).
