#!/bin/bash

# Create Breath iOS App Project Structure
echo "Creating Breath iOS App Project Structure..."

# Create main project directory
mkdir -p Breath.xcodeproj
mkdir -p Breath

# Create app structure
mkdir -p Breath/Views
mkdir -p Breath/ViewModels  
mkdir -p Breath/Models
mkdir -p Breath/Services
mkdir -p Breath/Utils
mkdir -p Breath/Resources
mkdir -p Breath/Safety
mkdir -p Breath/Training
mkdir -p Breath/Progress

# Create supporting files directory
mkdir -p Breath/Supporting\ Files

echo "✅ Project structure created successfully!"
echo "Next: Open Xcode and create new iOS project in the Breath directory" 