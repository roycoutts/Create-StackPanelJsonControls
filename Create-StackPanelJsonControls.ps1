Add-Type -AssemblyName PresentationFramework
$script:configPath = 'c:\temp\Create-StackPanelJsonControls.json'
$script:ControlList = @()

# Function to create the main GUI
function Create-DynamicGUI {
    try {
        # Read the config file
        if (-not (Test-Path $script:configPath)) {
            throw "Config file '$script:configPath' not found."
        }
        $config = Get-Content -Path $script:configPath -Raw | ConvertFrom-Json
        
        # Create the XAML for WPF
        $xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Dynamic GUI" Height="400" Width="300">
    <StackPanel Name="MainStackPanel" Margin="10">
    </StackPanel>
</Window>
"@

        # Convert XAML to XML and create the window
        $reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
        $window = [Windows.Markup.XamlReader]::Load($reader)

        # Get the StackPanel
        $stackPanel = $window.FindName("MainStackPanel")
        

        # Hashtable to store controls by ID
        $script:controls = @{}

        # Dynamically add controls based on config
        foreach ($control in $config.Controls) {
            Write-Host $control
            switch ($control.Type) {
                "Button" {
                    $btn = New-Object System.Windows.Controls.Button
                    $btn.Name = $control.ID
                    $btn.Content = $control.Label
                    $btn.Margin = "0,0.5,0,0.5"
                    $btn.Padding = "5,1,5,1"
                    if ($control.Action) {
                        $btn.Add_Click({
                            Invoke-Expression $control.Action
                        }.GetNewClosure())
                    }
                    if ($control.ID) {
                        $script:controls[$control.ID] = $btn
                    }
                    $stackPanel.Children.Add($btn)
                }

                "TextBox" {
                    $txt = New-Object System.Windows.Controls.TextBox
                    $txt.Name = $control.ID
                    $txt.Text = $control.DefaultText
                    $txt.Margin = "0,0.5,0,0.5"
                    $txt.Padding = "5,1,5,1"
                    $txt.Height = $control.Height
                    # Enable multiline if specified
                    if ($control.Multiline -eq $true) {
                        $txt.AcceptsReturn = $true
                        $txt.AcceptsTab = $true  # Optional: Allow tabs
                    }
                    # Add scrollbar if specified
                    if ($control.ScrollBars) {
                        switch ($control.ScrollBars) {
                            "Vertical"   { $txt.VerticalScrollBarVisibility   = "Auto" }
                            "Horizontal" { $txt.HorizontalScrollBarVisibility = "Auto" }
                            "Both"       { $txt.VerticalScrollBarVisibility   = "Auto"
                                           $txt.HorizontalScrollBarVisibility = "Auto" }
                        }
                    }
                    if ($control.ID) {
                        $script:controls[$control.ID] = $txt
                    }
                    $stackPanel.Children.Add($txt)
                }

                default {
                    Write-Warning "Unsupported control type: $($control.Type)"
                }
            }
        }

        # Show the window
        $window.ShowDialog()
    }
    catch {
        Write-Error "Error creating GUI: $_"
    }
}


function Get-Button {
    Return [PSCustomObject]@{
        Type   = "Button"
        ID     = "CreateButton"
        Label  = "Button"
        Action = "Create-Button"
    }
}

function Get-CheckBox {
    Return [PSCustomObject]@{
        Type   = "CheckBox"
        ID     = "CreateCheckBox"
        Label  = "CheckBox"
        Action = "Create-CheckBox"
        Parent = "CheckBoxParent"
    }
}

function Get-ComboBox {
    Return [PSCustomObject]@{
        Type   = "ComboBox"
        ID     = "CreateComboBox"
        Label  = "ComboBox"
        Action = "Create-ComboBox"
        Items  = @("a","b","c")
    }
}

function Get-DatePicker {
    Return [PSCustomObject]@{
        Type        = "DatePicker"
        ID          = "CreateDatePicker"
        Label       = "DatePicker"
        Action      = "Create-DatePicker"
        DefaultDate = (Get-Date).ToString("yyyy-MM-dd")
    }
}  

function Get-Label {
    Return [PSCustomObject]@{
        Type   = "Label"
        ID     = "CreateLabel"
        Label  = "Label"
        Action = "Create-Label"
    }
}

function Get-RadioButton {
    Return [PSCustomObject]@{
        Type   = "RadioButton"
        ID     = "CreateRadioButton"
        Label  = "RadioButton"
        Action = "Create-RadioButton"
        Parent = "RadioButtonParent"
    }
}

function Get-TextBox {
    Return [PSCustomObject]@{
        Type        = "TextBox"
        ID          = "CreateTextBox"
        DefaultText = "Textbox$([char]10)Line2$([char]10)Line3"
        Multiline   = $True
        ScrollBars  = "Vertical"
        Height      = 100
    }
}

function Get-WrapPanel {
    [PSCustomObject]@{
        Type = "WrapPanel"
        ID   = "CreateWrapPanel"
    }
}

$Controls = @()
$Controls += Get-Button
$Controls += Get-CheckBox
$Controls += Get-ComboBox
$Controls += Get-DatePicker
$Controls += Get-Label
$Controls += Get-RadioButton
$Controls += Get-TextBox
$Controls += Get-WrapPanel

# [PSCustomObject]@{ Controls = $Controls } | ConvertTo-Json | Out-File -FilePath "C:\Temp\new.json"

function Update-JsonText    { 
    $psoControls = @()
    ForEach ($item in $script:ControlList) {
        switch ($item) {
            'Button'      {$psoControls += Get-Button}
            'CheckBox'    {$psoControls += Get-CheckBox}
            'ComboBox'    {$psoControls += Get-ComboBox}
            'DatePicker'  {$psoControls += Get-DatePicker}
            'Label'       {$psoControls += Get-Label}
            'RadioButton' {$psoControls += Get-RadioButton}
            'TextBox'     {$psoControls += Get-TextBox}
            'WrapPanel'   {$psoControls += Get-WrapPanel}
        }
    }
    $script:controls["JSONTextBox"].Text = [PSCustomObject]@{ Controls = $psoControls} | ConvertTo-Json
}

function Create-Button      { $script:ControlList += 'Button'     ;Update-JsonText }
function Create-CheckBox    { $script:ControlList += 'CheckBox'   ;Update-JsonText }
function Create-ComboBox    { $script:ControlList += 'ComboBox'   ;Update-JsonText }
function Create-DatePicker  { $script:ControlList += 'DatePicker' ;Update-JsonText }
function Create-Label       { $script:ControlList += 'Label'      ;Update-JsonText }
function Create-RadioButton { $script:ControlList += 'RadioButton';Update-JsonText }
function Create-TextBox     { $script:ControlList += 'TextBox'    ;Update-JsonText }
function Create-WrapPanel   { $script:ControlList += 'WrapPanel'  ;Update-JsonText }
function Remove-Control     { $script:ControlList = 0..($script:ControlList.Count - 2) | % { $script:ControlList[$_] };Update-JsonText }


$window.Content
# Run the GUI
Create-DynamicGUI


