%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "test/", "config/", "mix.exs"],
        excluded: ["_build/", "deps/", "dist/"]
      },
      strict: true,
      color: true,
      checks: [
        {Credo.Check.Design.TagTODO, false},
        {Credo.Check.Readability.ModuleDoc, false},
        {Credo.Check.Readability.Specs, false},
        {Credo.Check.Refactor.CyclomaticComplexity, max_complexity: 15},
        {Credo.Check.Refactor.Nesting, max_nesting: 3}
      ]
    }
  ]
}
