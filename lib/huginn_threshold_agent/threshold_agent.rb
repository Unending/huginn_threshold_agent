module Agents
  class ThresholdAgent < Agent
    cannot_be_scheduled!

    description <<-MD
      The Threshold Agent emits events only when, compared to the previous event, it exceeds a specified value.

      `property` specifies a [Liquid](https://github.com/huginn/huginn/wiki/Formatting-Events-using-Liquid) template that expands to the property to be watched, where you can use a variable `last_property` for the last property value.

      `threshold` The threshold value, must be a number.

      `mode` In which direction should the threshold be passed to emit an event, `increase`, `decrease` or `both`.
    MD

    def default_options
      {
        'expected_update_period_in_days' => '10',
        'property' => '{{property}}',
        'threshold' => 1000,
        'mode' => 'increase'
      }
    end

    def validate_options
      unless options['property'].present? && options['expected_update_period_in_days'].present?
        errors.add(:base, "The property and expected_update_period_in_days fields are all required.")
      end

      errors.add(:base, "mode has invalid value: should be 'increase', `decrease` or 'both'") if interpolated['mode'].present? && !%w(increase decrease both).include?(interpolated['mode'])
    end

    def working?
      event_created_within?(interpolated['expected_update_period_in_days']) && !recent_error_logs?
    end

    def receive(incoming_events)
      incoming_events.each do |event|
        interpolation_context.stack do
          interpolation_context['last_property'] = last_property
          handle(interpolated(event), event)
        end
      end
    end

    private

    def handle(opts, event = nil)
      property = opts['property'].to_i
      threshold = options['threshold'].to_i
      mode = options['mode']

      if ['increase', 'both'].include? mode
        if property > threshold && last_property < threshold
          create_event :payload => event.payload
        end
      end

      if ['decrease', 'both'].include? mode
        if property < threshold && last_property > threshold
          create_event :payload => event.payload
        end
      end

      self.memory['last_property'] = property
    end

    def last_property
      self.memory['last_property'].to_i
    end
  end
end
