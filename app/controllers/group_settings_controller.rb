# this is a workaround to give the ability to style Formotion controls
module Formotion
  class Form < Formotion::Base
    def tableView(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
      # cell.textLabel.textColor = UIColor.greenColor
    end
  end
end

class GroupSettingsController < Formotion::FormController

  def initWithGroup(group)
    @group = group
    self.initWithForm(create_form)

    self.title = "Group Settings"
    self.view.backgroundColor = UIColor.whiteColor

    # seems to be the only way to style the form currently in Formotion
    self.form.instance_eval do
      def tableView(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
        if submit_button?(cell)
          cell.textColor = UIColor.whiteColor
          cell.contentView.backgroundColor = Group::COLOR
        end
      end

      def submit_button?(cell)
        ["Update Settings"].include?(cell.text)
      end
    end

    self
  end

  def viewDidLoad
    super
  end

  def viewWillAppear(animated)
    super

    if @form
      @form.values = {
        name: @group.name,
        password: @group.password,
        max_score: @group.max_score,
        interval: @group.interval,
        exclude_score_after_weeks: @group.exclude_score_after_weeks
      }
    end
  end

  def create_form
    @form = Formotion::Form.new({
      sections: [{
        title: "",
        rows: [
          {
            title: "Name",
            key: :name,
            value: @group.name,
            type: :string,
            input_accessory: :done
          },
          {
            title: "Password",
            key: :password,
            value: "********",
            type: :string,
            input_accessory: :done
          },
          {
            title: "Maximum Score",
            key: :max_score,
            items: (1..10).map { |v| [v.to_s, v.round(1).to_s] },
            value: @group.max_score.to_i.to_s,
            type: :picker,
            input_accessory: :done
          },
          {
            title: "Interval",
            key: :interval,
            items: [0.1, 0.5, 1.0].map { |v| v.round(1).to_s },
            value: @group.interval.to_f.round(1).to_s,
            type: :picker,
            input_accessory: :done
          },
          {
            title: "Exclude Score After Weeks",
            key: :exclude_score_after_weeks,
            items: ["0", "1", "2", "3", "4", "6", "12"],
            value: @group.exclude_score_after_weeks.to_i.to_s,
            type: :picker,
            input_accessory: :done
          },
          {
            title: "Update Settings",
            key: :update_settings,
            type: :submit
          }
        ]
      }]
    })

    @form.on_submit do |form|
      data = form.render

      ApiHandler.alloc.init.update_group(data) do |result|
        if result.success?
          self.navigationController.popViewControllerAnimated(true)
        end
      end
    end

    @form
  end

end
