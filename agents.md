# ImageJ Macro Language Guide for Coding Agents

## Language Overview

ImageJ Macro Language (IJM) is a scripting language built into ImageJ for automating image processing tasks. It's a dynamically-typed, interpreted language with Java-like syntax.

## Core Language Features

### Variables
- **Type System**: Mostly typeless - variables don't need declarations and can hold numbers, strings, or arrays
- **Numbers**: Stored as 64-bit double-precision floating point
- **Strings**: Text values in quotes
- **Arrays**: Created with `newArray()` or by listing elements
- **Case Sensitivity**: Variable names are case-sensitive
- **Global Variables**: Declared with `var` keyword before macro functions

```javascript
// Examples
v = 1.23;                    // number
name = "Hello";              // string  
arr = newArray(10, 20, 30);  // array
var globalVar = 42;          // global variable
```

### Operators
```
Arithmetic: +, -, *, /, %, ^
Comparison: ==, !=, <, >, <=, >=
Logical: &&, ||, !
Bitwise: &, |, ~, <<, >>
String concatenation: +
Assignment: =, +=, -=, *=, /=
```

### Control Structures

```javascript
// If/else
if (condition) {
    // code
} else {
    // code
}

// For loop
for (i=0; i<10; i++) {
    // code
}

// While loop
while (condition) {
    // code
}

// Do-while loop
do {
    // code
} while (condition);
```

### Functions

```javascript
// User-defined function
function myFunction(arg1, arg2) {
    // code
    return result;
}

// Calling functions
result = myFunction(10, 20);
```

## Essential Built-in Functions

### Image Operations
- `open(path)` - Opens an image file
- `save(path)` - Saves current image
- `close()` - Closes current image
- `newImage(title, type, width, height, depth)` - Creates new image
- `getTitle()` - Returns current image title
- `getDimensions(width, height, channels, slices, frames)` - Gets image dimensions

### Pixel Operations
- `getPixel(x, y)` - Gets pixel value at coordinates
- `setPixel(x, y, value)` - Sets pixel value
- `getValue(x, y)` - Gets calibrated pixel value
- `changeValues(v1, v2, v3)` - Changes pixel values in range

### Selection/ROI Operations
- `makeRectangle(x, y, width, height)` - Creates rectangular selection
- `makeOval(x, y, width, height)` - Creates oval selection
- `makeLine(x1, y1, x2, y2)` - Creates line selection
- `run("Measure")` - Measures current selection
- `roiManager("Add")` - Adds selection to ROI Manager

### Dialog Functions
- `Dialog.create(title)` - Creates dialog
- `Dialog.addNumber(label, default)` - Adds numeric field
- `Dialog.addString(label, default)` - Adds text field
- `Dialog.addCheckbox(label, default)` - Adds checkbox
- `Dialog.show()` - Shows dialog
- `Dialog.getNumber()` - Gets numeric value
- `Dialog.getString()` - Gets string value

### File Operations
- `File.exists(path)` - Checks if file exists
- `File.open(path)` - Opens file for writing
- `File.openAsString(path)` - Reads file as string
- `File.saveString(string, path)` - Saves string to file
- `getDirectory("Choose a Directory")` - Shows directory dialog

### Output Functions
- `print(message)` - Prints to Log window
- `showMessage(title, message)` - Shows message dialog
- `showStatus(message)` - Shows in status bar
- `showProgress(progress)` - Updates progress bar (0.0-1.0)

## Running Menu Commands

Use `run(command, options)` to execute any ImageJ menu command:

```javascript
run("Gaussian Blur...", "sigma=2");
run("8-bit");
run("Threshold...", "method=Otsu");
```

## Batch Processing

```javascript
setBatchMode(true);  // Hide windows for speed
// processing code
setBatchMode(false); // Show results
```

## Common Patterns

### Processing All Files in Directory
```javascript
dir = getDirectory("Choose a Directory");
list = getFileList(dir);
for (i=0; i<list.length; i++) {
    if (endsWith(list[i], ".tif")) {
        open(dir + list[i]);
        // process image
        save(dir + "processed_" + list[i]);
        close();
    }
}
```

### Measuring Multiple ROIs
```javascript
roiManager("Reset");
// Add ROIs
for (i=0; i<roiManager("Count"); i++) {
    roiManager("Select", i);
    run("Measure");
}
```

### Creating Dialogs
```javascript
Dialog.create("Parameters");
Dialog.addNumber("Threshold:", 128);
Dialog.addCheckbox("Apply filter", true);
Dialog.show();
threshold = Dialog.getNumber();
doFilter = Dialog.getCheckbox();
```

## Important Notes

1. **Strings in run() commands**: Options are passed as space-separated key=value pairs
2. **Case sensitivity**: Function and variable names are case-sensitive
3. **Parentheses**: Optional for built-in functions without arguments (e.g., `nImages` or `nImages()`)
4. **Arrays**: Auto-expand in ImageJ 1.53g+ or with `setOption("ExpandableArrays", true)`
5. **Coordinates**: Origin (0,0) is top-left corner
6. **Progress bars**: Automatically shown for loops, use `showProgress()` for custom progress

## Error Handling

```javascript
if (!File.exists(path)) {
    exit("File not found: " + path);
}

if (nImages == 0) {
    exit("No images open");
}
```

## Debugging

- Use `print()` liberally for debugging
- Command Recorder (Plugins > Macros > Record) generates macro code
- Debug menu in macro editor (Ctrl+D to start debugging)
- `dump()` shows symbol table and variables

## File Extensions

- Macro files should have `.ijm` or `.txt` extension
- Place in `plugins` folder with underscore in name for menu item
- `StartupMacros.txt` in macros folder runs at startup