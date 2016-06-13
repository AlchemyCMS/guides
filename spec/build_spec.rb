require "spec_helper"

describe "guides build" do

  describe "production" do

    before(:all) do
      reset_tmp
      guides "new", "sample" and wait
      copy_fixtures
      Dir.chdir tmp.join("sample")
      guides "build" and wait
    end

    it "generates the app" do
      out.should == "Generating article_one.html\nGenerating article_three.html\n" +
        "Generating article_two.html\nGenerating contribute.html\nGenerating credits.html\nGenerating index.html\n"
    end

    it "generates assets" do
      files = Dir["output/*"]

      File.directory?("output/images").should be_truthy
      File.directory?("output/javascripts").should be_truthy
      File.directory?("output/stylesheets").should be_truthy
      File.file?("output/javascripts/guides.js").should be_truthy
      File.file?("output/stylesheets/main.css").should be_truthy
      File.file?("output/stylesheets/overrides.style.css").should be_truthy
    end

    it "does nothing if run twice in a row" do
      guides "build"
      out.should be_blank
    end

    it "re-runs if run with --clean" do
      guides "build", "--clean"
      out.should == "Generating article_one.html\nGenerating article_three.html\n" +
        "Generating article_two.html\nGenerating contribute.html\nGenerating credits.html\nGenerating index.html\n"
    end

    it "creates index.html" do
      index = File.read("output/index.html")
      index.should =~ /<a href="article_one.html">/
      # Test _sections.html.erb with .html.erb templates
      index.should =~ /This work is licensed under/
    end

    it "should not show under-construction articles in index" do
      File.read("output/index.html").should_not =~ /<a href="article_four.html">/
    end

    it "creates contribute.html" do
      contribute = File.read("output/contribute.html")
      contribute.should =~ /<h2>Contribute<\/h2>/
      # Test _sections.html.erb with .textile templates
      contribute.should =~ /This work is licensed under/
    end

    it "creates normal article" do
      article_one = File.read("output/article_one.html")
      article_one.should =~ /<h2>Article One<\/h2>/
    end

    it "creates markdown article" do
      article_two = File.read("output/article_two.html")
      article_two.should =~ /<h2[^>]*>Article Two<\/h2>/
    end

    it "does not create under-construction article" do
      File.exist?("output/article_four.html").should be_falsey
    end

    it "shows current guide file name" do
      article_two = File.read("output/article_three.html")
      article_two.should =~ /<aside class="guide-name">article_three.textile<\/aside>/
    end
  end

  describe "development" do

    before(:all) do
      reset_tmp
      guides "new", "sample" and wait
      copy_fixtures
      Dir.chdir tmp.join("sample")
      guides "build", "--production=false" and wait
    end

    it "generates the app" do
      out.should == "Generating article_four.html\nGenerating article_one.html\nGenerating article_three.html\n" +
        "Generating article_two.html\nGenerating contribute.html\nGenerating credits.html\nGenerating index.html\n"
    end

    it "should show under-construction articles in index" do
      File.read("staging/index.html").should =~ /<a href="article_four.html">/
    end

    it "creates under construction article" do
      article_four = File.read("staging/article_four.html")
      article_four.should =~ /<h2>Article Four<\/h2>/
    end

  end

end
