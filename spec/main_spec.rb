describe "Happiness Metric" do
  before do
    @app = UIApplication.sharedApplication
  end

  it "has one window" do
    @app.windows.each { |w| puts "---- #{w.inspect}" }
    @app.windows.size.should == 2
  end
end
