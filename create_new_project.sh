#!/bin/bash

echo "🚀 Creating a new Breath Training App Xcode project..."

# Create a temporary directory for the new project
TEMP_DIR="../breath_temp"
PROJECT_NAME="Breath"

echo "📁 Creating temporary directory..."
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

echo "🔨 You'll need to manually create the Xcode project. Here's what to do:"
echo ""
echo "1. Open Xcode"
echo "2. Choose 'Create a new Xcode project'"
echo "3. Select 'iOS' > 'App'"
echo "4. Configure your project:"
echo "   - Product Name: Breath"
echo "   - Interface: SwiftUI"
echo "   - Language: Swift"
echo "   - Use Core Data: NO"
echo "   - Include Tests: YES (optional)"
echo "5. Save it to: $TEMP_DIR"
echo ""
echo "Once you've created the project, run this script again with 'copy' argument:"
echo "./create_new_project.sh copy"
echo ""

if [ "$1" = "copy" ]; then
    echo "📋 Copying all source files..."
    
    # Go back to original directory
    cd "../breath"
    
    # Copy all Swift files to the new project
    if [ -d "$TEMP_DIR/Breath" ]; then
        echo "Copying Swift source files..."
        
        # Copy main app files
        cp Breath/BreathApp.swift "$TEMP_DIR/Breath/"
        cp Breath/ContentView.swift "$TEMP_DIR/Breath/"
        
        # Create directories and copy files
        mkdir -p "$TEMP_DIR/Breath/Models"
        cp Breath/Models/*.swift "$TEMP_DIR/Breath/Models/" 2>/dev/null || true
        
        mkdir -p "$TEMP_DIR/Breath/Services"
        cp Breath/Services/*.swift "$TEMP_DIR/Breath/Services/" 2>/dev/null || true
        
        mkdir -p "$TEMP_DIR/Breath/Views"
        cp Breath/Views/*.swift "$TEMP_DIR/Breath/Views/" 2>/dev/null || true
        
        mkdir -p "$TEMP_DIR/Breath/Safety"
        cp Breath/Safety/*.swift "$TEMP_DIR/Breath/Safety/" 2>/dev/null || true
        
        mkdir -p "$TEMP_DIR/Breath/Training"
        cp Breath/Training/*.swift "$TEMP_DIR/Breath/Training/" 2>/dev/null || true
        
        mkdir -p "$TEMP_DIR/Breath/Progress"
        cp Breath/Progress/*.swift "$TEMP_DIR/Breath/Progress/" 2>/dev/null || true
        
        echo "✅ Files copied successfully!"
        echo ""
        echo "📝 Next steps:"
        echo "1. Open the new project: $TEMP_DIR/Breath.xcodeproj"
        echo "2. Add all the copied Swift files to your Xcode project:"
        echo "   - Right-click on the Breath folder in Xcode"
        echo "   - Choose 'Add Files to Breath'"
        echo "   - Select all the Swift files in the respective folders"
        echo "3. Build and run the project!"
        echo ""
        echo "🎯 The app should now work properly in the simulator!"
        
    else
        echo "❌ Could not find the new Xcode project at $TEMP_DIR/Breath"
        echo "Please make sure you created the project first!"
    fi
fi 