# Create-StackPanelJsonControls

# Create-StackPanelJsonControls.ps1 

PowerShell Documentation

## Overview

This PowerShell script dynamically creates a Windows Presentation Foundation (WPF) GUI based on a JSON configuration file. It reads control definitions from a JSON file, creates the corresponding WPF controls (such as Buttons and TextBoxes), and adds them to a StackPanel in a dynamically generated window. In addition, the script supports adding new controls interactively through button click events, updating a JSON preview in real time.

## Prerequisites

- **Operating System:** Windows (WPF is supported only on Windows)
- **PowerShell Version:** PowerShell 5.0 or later is recommended.
- **.NET Assemblies:** The script requires the `PresentationFramework` assembly (loaded via `Add-Type -AssemblyName PresentationFramework`).

## File Structure

- **Script File:** `Create-StackPanelJsonControls.ps1`
- **Configuration File:** `Create-StackPanelJsonControls.json`

## Configuration File

The JSON configuration file defines the initial set of controls to be loaded into the GUI. An example structure is shown below:

```json

{
    "Controls":  [
        {
            "Type":  "Button",
            "ID":  "CreateButton",
            "Label":  "Button",
            "Action":  "Create-Button"
        },
        {
            "Type":  "Button",
            "ID":  "CreateCheckBox",
            "Label":  "CheckBox",
            "Action":  "Create-CheckBox"
        },
        {
            "Type":  "Button",
            "ID":  "CreateComboBox",
            "Label":  "ComboBox",
            "Action":  "Create-ComboBox"
        },
        {
            "Type":  "Button",
            "ID":  "CreateDatePicker",
            "Label":  "DatePicker",
            "Action":  "Create-DatePicker"
        },
        {
            "Type":  "Button",
            "ID":  "CreateLabel",
            "Label":  "Label",
            "Action":  "Create-Label"
        },
        {
            "Type":  "Button",
            "ID":  "CreateRadioButton",
            "Label":  "RadioButton",
            "Action":  "Create-RadioButton"
        },
        {
            "Type":  "Button",
            "ID":  "CreateTextBox",
            "Label": "TextBox",
            "Action": "Create-TextBox"
        },
        {
            "Type": "Button",
            "ID": "CreateWrapPanel",
            "Label": "WrapPanel",
            "Action": "Create-WrapPanel"
        },
        {
            "Type": "Button",
            "ID": "RemoveControl",
            "Label": "Remove Control",
            "Action": "Remove-Control"
        },
        {
            "Type": "TextBox",
            "DefaultText": "",
            "ID": "JSONTextBox",
            "Multiline": true,
            "ScrollBars": "Vertical",
            "Height": 200
        }
    ]
}
```

## Script Structure and Functions

### Global Variables

- **`$script:configPath`**  
  Specifies the path to the JSON configuration file.

- **`$script:ControlList`**  
  An array that holds the list of control types added via user interaction.

### Primary Functions

#### Create-DynamicGUI

- **Purpose:**  
  Builds and displays the main GUI window by:
  - Reading and parsing the JSON configuration.
  - Generating a WPF window using XAML.
  - Dynamically creating controls (currently supporting _Button_ and _TextBox_ types) based on the configuration.

- **Process:**
  1. **Config File Validation:**  
     Checks whether the configuration file exists. If not, it throws an error.
  2. **JSON Parsing:**  
     Reads the JSON file and converts it into a PowerShell object.
  3. **XAML Window Creation:**  
     Defines a simple XAML layout containing a StackPanel named `"MainStackPanel"` and creates a WPF window from it.
  4. **Control Creation:**  
     Iterates over the list of controls from the configuration file. For each control, a `switch` statement creates the appropriate WPF element:
     - For _Button_ types: Creates a Button, assigns properties (Name, Content, Margin, Padding), and attaches a click event that executes a corresponding action.
     - For _TextBox_ types: Creates a TextBox, applies default text, sets margins, padding, and additional properties for multiline input and scrollbars if specified.
  5. **Display:**  
     The window is displayed using the `ShowDialog()` method.
  
- **Error Handling:**  
  A try-catch block is implemented to capture and display errors (e.g., missing config file or JSON parsing errors).

#### Get-Control Functions

A set of helper functions returns PSCustomObjects representing the configurations for various controls. These include:

- **`Get-Button`**
- **`Get-CheckBox`**
- **`Get-ComboBox`**
- **`Get-DatePicker`**
- **`Get-Label`**
- **`Get-RadioButton`**
- **`Get-TextBox`**
- **`Get-WrapPanel`**

Each function returns an object with properties such as `Type`, `ID`, `Label`, and `Action` (where applicable). For example:

- **Get-Button**  
  Returns:
  ```powershell
  [PSCustomObject]@{
      Type   = "Button"
      ID     = "CreateButton"
      Label  = "Button"
      Action = "Create-Button"
  }
  ```

These functions are used when creating a dynamic JSON preview and when adding controls interactively.

#### Update-JsonText

- **Purpose:**  
  Updates the content of the control with ID `"JSONTextBox"` to display a JSON representation of the current control list.

- **Process:**
  1. Iterates over the global `$script:ControlList`.
  2. Uses the corresponding `Get-*` functions to build an array of control objects.
  3. Converts this array into a JSON string.
  4. Updates the TextBox’s `Text` property with this JSON.

#### Action Functions

These functions serve as event handlers that are linked to the buttons defined in the JSON configuration. They include:

- **`Create-Button`**
- **`Create-CheckBox`**
- **`Create-ComboBox`**
- **`Create-DatePicker`**
- **`Create-Label`**
- **`Create-RadioButton`**
- **`Create-TextBox`**
- **`Create-WrapPanel`**
- **`Remove-Control`**

Each function appends a control type (as a string) to `$script:ControlList` and calls `Update-JsonText` to refresh the JSON preview. The `Remove-Control` function modifies the list by removing the most recently added control.

## How to Use the Script

1. **Prepare the Environment:**
   - Ensure the JSON file (`Create-StackPanelJsonControls.json`) is saved at `C:\temp\Create-StackPanelJsonControls.json`.
   - Verify that the JSON is well-formed and matches the expected structure.

2. **Run the Script:**
   - Open a PowerShell prompt.
   - Execute the script:
     ```powershell
     .\Create-StackPanelJsonControls.ps1
     ```
   - A GUI window titled “Dynamic GUI” will appear.

3. **Interacting with the GUI:**
   - **Buttons:**  
     Click on any of the dynamically created buttons to add new control configurations. Each button click adds an entry to the global control list and updates the JSON preview.
   - **JSON Preview:**  
     The `TextBox` with the ID `"JSONTextBox"` displays the current JSON configuration of all added controls.
   - **Removing Controls:**  
     Use the “Remove Control” button to remove the last control added, which then updates the JSON preview.

## Extending and Customizing

- **Adding New Control Types:**
  - Create a new helper function (e.g., `Get-NewControlType`) that returns a PSCustomObject with the desired properties.
  - Update the switch statement in the `Create-DynamicGUI` function to handle the new control type.
  - Write an associated action function (e.g., `Create-NewControlType`) that adds the new type to `$script:ControlList` and calls `Update-JsonText`.

- **Modifying the GUI Layout:**
  - Adjust the XAML string within `Create-DynamicGUI` to change window dimensions, styling, or to add new layout containers.
  - Change control-specific properties (such as margins, padding, or default text) directly within the control creation code.

## Error Handling

- The script uses error handling (try-catch) in the `Create-DynamicGUI` function. If the configuration file is missing or if there’s an error during JSON parsing, a descriptive error message is output using `Write-Error`.

## Conclusion

**Create-StackPanelJsonControls.ps1** offers a flexible and interactive way to generate a dynamic GUI based on a JSON configuration file. By separating control definitions into individual functions and leveraging WPF via XAML, the script is easy to extend and customize. It is particularly useful for scenarios where you want to dynamically modify the interface and immediately view the changes reflected in a JSON structure.

---

Use this documentation as a reference to understand, run, and extend the script as needed.
