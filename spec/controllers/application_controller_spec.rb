describe "application controller" do

  tests ApplicationController

  before do
    controller.group = Group.default
  end

  # it "increases the score when the increaser button is tapped" do
  #   tap "score increaser"
  #   controller.score.should == 0.5
  # end

  # describe "#viewDidLoad" do

  #   it "sets the correct title" do
  #     controller.title.should == "Happiness Metric"
  #   end
  # end

end