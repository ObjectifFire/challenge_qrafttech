echo "=== Running Tests for All Levels ==="
echo

echo "Installing gems..."
bundle install --quiet

for level in {1..5}; do
    echo "=== Level $level Tests ==="
    cd "level$level"
    
    echo "Running tests for level $level..."
    if [ -d "spec" ]; then
        bundle exec rspec spec/ --require ../spec_helper.rb --format documentation
    else
        echo "No tests found for level $level"
    fi
    
    echo
    cd ..
done

echo "=== All Tests Complete ==="
