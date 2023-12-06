import math

def add(x, y):
    return x + y

def subtract(x, y):
    return x - y

def multiply(x, y):
    return x * y

def divide(x, y):
    if y != 0:
        return x / y
    else:
        return "Error: Division by zero"

def square_root(x):
    if x >= 0:
        return math.sqrt(x)
    else:
        return "Error: Cannot calculate square root of a negative number"

def power(x, y):
    return x ** y

def sin(x):
    return math.sin(math.radians(x))

def cos(x):
    return math.cos(math.radians(x))

def tan(x):
    return math.tan(math.radians(x))

def scientific_calculator():
    print("Scientific Calculator")
    print("Operations:")
    print("1. Addition (+)")
    print("2. Subtraction (-)")
    print("3. Multiplication (*)")
    print("4. Division (/)")
    print("5. Square Root (√)")
    print("6. Power (^)")
    print("7. Sine (sin)")
    print("8. Cosine (cos)")
    print("9. Tangent (tan)")

    choice = input("Enter choice (1-9): ")

    if choice not in ['1', '2', '3', '4', '5', '6', '7', '8', '9']:
        print("Invalid choice")
        return

    if choice in ['1', '2', '3', '4', '6']:
        num1 = float(input("Enter first number: "))
        num2 = float(input("Enter second number: "))
    elif choice in ['5']:
        num1 = float(input("Enter a number: "))
    elif choice in ['7', '8', '9']:
        num1 = float(input("Enter an angle in degrees: "))

    if choice == '1':
        result = add(num1, num2)
    elif choice == '2':
        result = subtract(num1, num2)
    elif choice == '3':
        result = multiply(num1, num2)
    elif choice == '4':
        result = divide(num1, num2)
    elif choice == '5':
        result = square_root(num1)
    elif choice == '6':
        num2 = float(input("Enter the exponent: "))
        result = power(num1, num2)
    elif choice == '7':
        result = sin(num1)
    elif choice == '8':
        result = cos(num1)
    elif choice == '9':
        result = tan(num1)

    print(f"Result: {result}")

if __name__ == "__main__":
    scientific_calculator()

#
#This updated code includes additional functions for square root, power, and trigonometric operations (sin, cos, tan). The trigonometric functions use degrees as input, and the math.radians function is used to convert degrees to radians before performing the calculations. You can further expand the calculator by adding more functions based on your requirements.
#
