# Only need one global context for now
defmodule EyeTest.Data do
  def compute_scores(assessment) do
    # Gather data
    questions = assessment.questions
    correct_sizes = questions |> Enum.filter(& &1.correct) |> Enum.map(& &1.size)
    incorrect_sizes = questions |> Enum.filter(& !&1.correct) |> Enum.map(& &1.size)
    smallest_3_correct = correct_sizes |> Enum.sort_by(& &1) |> Enum.slice(0, 3)
    smallest_correct = correct_sizes |> Enum.sort_by(& &1) |> List.first
    largest_incorrect = incorrect_sizes |> Enum.sort_by(& (0 - &1)) |> List.first

    # Compute scores
    avg_smallest_3_correct = Enum.sum(smallest_3_correct) / length(smallest_3_correct)
    edge_size = (smallest_correct + largest_incorrect) / 2

    scores = %{
      "avg_smallest_3_correct" => Float.round(avg_smallest_3_correct, 2),
      "edge_size" => Float.round(edge_size, 2)
    }

    Map.put(assessment, :scores, scores)
  end
end
