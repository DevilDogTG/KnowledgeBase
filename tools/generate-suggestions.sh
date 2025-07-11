#!/bin/bash
# Topic Suggestion Generator - Simple wrapper script

echo "🚀 DevDogs Knowledge Base - Topic Suggestion Tool"
echo "================================================="
echo

# Change to the repository root directory
cd "$(dirname "$0")/.."

# Run the Python script
python3 tools/topic-suggestions.py

echo
echo "✅ Topic suggestions generated successfully!"
echo "💡 Use these suggestions to inspire your next article or blog post."
echo
echo "📝 Next steps:"
echo "   1. Review the suggestions above"
echo "   2. Pick a topic that interests you"
echo "   3. Create a new article in the appropriate category"
echo "   4. Update the index files (README.md, Blog Index.md)"
echo
echo "🔧 Want to regenerate suggestions? Run this script again anytime!"