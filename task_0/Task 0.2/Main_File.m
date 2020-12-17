pkg load symbolic      # Load the octave symbolic library
syms x1 x2             # Define symbolic variables x1 and x1

x1_dot = -x1 + 2*x1^3 + x2;
x2_dot = -x1 - x2;

[equilibrium_points jacobians eigen_values stability] = main_function(x1_dot, x2_dot);