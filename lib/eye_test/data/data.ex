# Only need one global context for now
defmodule EyeTest.Data do
  def compute_scores(assessment) do
    # Originally I tried a few complicated score algorithms, but in the end, I don't think
    # anything is more accurate than simply "the smallest size I got correct".
    #
    # Old logic:
    # correct_sizes = assessment.questions |> Enum.filter(& &1.correct) |> Enum.map(& &1.size)
    # incorrect_sizes = questions |> Enum.filter(& !&1.correct) |> Enum.map(& &1.size)
    # smallest_correct = correct_sizes |> Enum.sort_by(& &1) |> List.first
    # smallest_3_correct = correct_sizes |> Enum.sort_by(& &1) |> Enum.slice(0, 3)
    # largest_incorrect = incorrect_sizes |> Enum.sort_by(& (0 - &1)) |> List.first
    # avg_smallest_3_correct = Enum.sum(smallest_3_correct) / length(smallest_3_correct)
    # edge_size = (smallest_correct + largest_incorrect) / 2

    smallest_correct =
      assessment.questions
      |> Enum.filter(& &1.correct)
      |> Enum.map(& &1.size)
      |> Enum.sort_by(& &1)
      |> List.first()

    scores = %{"smallest_correct" => Float.round(smallest_correct, 2)}
    Map.put(assessment, :scores, scores)
  end
end
