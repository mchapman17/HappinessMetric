class GroupSettingsController < Formotion::FormController

  def initWithGroup(group)
    @group = group
    self.initWithForm(create_form)

    self.title = "Group Settings"
    self.view.backgroundColor = UIColor.whiteColor
    self
  end

  def viewDidLoad
    super
  end

  def create_form
    Formotion::Form.new({
      sections: [{
        title: "",
        rows: [
          {
            title: "Name",
            key: :group_name,
            value: @group.name,
            type: :string,
            input_accessory: :done,
            done_action: lambda { save }
          },
          {
            title: "Password",
            key: :password,
            value: "********",
            type: :string,
            input_accessory: :done,
            done_action: lambda { save }
          },
          {
            title: "Maximum Score",
            key: :maximum_score_picker,
            items: (1..10).map { |v| v.to_s },
            value: @group.max_score.to_i.to_s,
            type: :picker,
            input_accessory: :done,
            done_action: lambda { save }
          },
          {
            title: "Interval",
            key: :interval_picker,
            items: (0.1..1.0).step(0.1).map { |v| v.round(1).to_s },
            value: @group.interval.to_f.round(1).to_s,
            type: :picker,
            input_accessory: :done,
            done_action: lambda { save }
          },
          {
            title: "Exclude Score After Weeks",
            key: :exclude_score,
            items: ["0", "1", "2", "3", "4", "6", "12"],
            value: @group.exclude_score_after_weeks.to_i.to_s,
            type: :picker,
            input_accessory: :done,
            done_action: lambda { save }
          },
          {
            title: "Reset Scores",
            key: :reset_scores,
            type: :static
          }
        ]
      }]
    })
  end

  def save
    data = self.form.render
    @group.name = data[:group_name]
    @group.password = data[:password]
    @group.max_score = data[:maximum_score_picker].to_f.round(1)
    @group.interval = data[:interval_picker].to_f.round(1)
    @group.save
  end

end
