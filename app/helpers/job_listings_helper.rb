module JobListingsHelper
  def expires_in(job_listing)
    distance_of_time_in_words(Date.current, job_listing.duration_ends_at)
  end

  def true_false(condition)
    if condition == true
      fa_icon 'check', class: 'true'
    else
      fa_icon 'times', class: 'false'
    end
  end

  def selected_classification(classification)
    case classification
    when 'employee'; 'Employee'
    when 'temporary'; 'Temporary/Contract'
    when 'intern'; 'Intern'
    when 'seasonal'; 'Seasonal'
    end
  end

  def selected_status(status)
    case status
    when 'full_time'; 'Full Time'
    when 'part_time'; 'Part Time'
    when 'per_diem'; 'Per Diem'
    end
  end
end
