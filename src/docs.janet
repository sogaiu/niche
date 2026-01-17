(def usage
  ``
  Usage: niche [<file-or-dir>...]

         niche [--help|[-h[h[h[h]]]]]
         niche [-v|--version]

  Nimbly Interpret Comment-Hidden Expressions

  Parameters:

    <file-or-dir>          path to file or directory

  Options:

    -h, --help             show this output
    -hh                    show background material
    -hhh                   show tutorial
    -hhhh                  show reference

    -v, --version          show version information

  Configuration:

    .niche.jdn             configuration file

  Example uses:

    1. Create and run comment-hidden expression tests in `src/`
       directory:

       $ niche src

    2. A configuration file (`.niche.jdn`) can be used to
       specify paths to operate on and avoid spelling out paths
       at the command line:

       $ niche

    3. `niche` can be used via `jeep`, `jpm`, etc. with some
       setup.  In a project's root directory, create a suitable
       `.niche.jdn` file and a runner file in the project's
       `test/` subdirectory.  Then, in the case of `jeep`:

       $ jeep test

  Example `.niche.jdn` configuration file:

    {# what to work on - file and dir paths
     :includes ["src" "bin/my-script"]
     # what to skip - file paths only
     :excludes ["src/sample.janet"]}

  Example runner file `test/trigger-niche.janet`:

    # adjust the path as needed
    (import ../niche) # niche.janet is in project root

    (niche/main)
  ``)

(def background
  ``
  Background
  ==========

  Introduction
  ------------

  While developing a function [1], it is probably not too
  uncommon to become curious about how the function in its
  current state actually behaves.  In such a situation, it
  seems likely one may end up calling the function with
  specific arguments to observe the results.

  This process of calling the function as it is developed may
  be repeated multiple times.  It is a curious thing that it is
  not unusual for these calls and their results to be
  discarded and subsequently to manually enter some of them
  again.

  What if it were very easy to keep these around and
  conveniently re-execute them to check their results as the
  function in question is worked on?  Perhaps even retaining
  these saved "calls with their results" afterwards to use for
  automated testing?

  `niche` is a tool for Janet code to help with this [2].

  Brief Explanation
  -----------------

  The basic idea is to place appropriate expressions within
  `comment` forms, apply `niche` to evaluate them, and
  interpret the results.  A simple example of the type of
  `comment` form mentioned is:

    (comment

      (function-to-test arg1 arg2)
      # =>
      :expected-value

      )

  The content of such `comment` forms is sometimes referred to
  as "comment-hidden expressions".

  About the Name
  --------------

  The name `niche` is short for:

    "Nimbly Interpret Comment-Hidden Expressions"

  Goals and Non-goals
  -------------------

  It is a non-goal of `niche` to be a comprehensive testing
  tool.  It's more meant to:

  * aid early and exploratory development,

  * provide a way to record testable illustrative examples
    for future code readers, and

  * be used alongside other testing tools and libraries

  Further Information
  -------------------

  See the tutorial and/or reference documentation for further
  details.

  The source code for `niche` (in the `src` directory of the
  repository) contains tests for `niche` itself using
  comment-hidden expressions.

  [1] ...or macro or just some expression.

  [2] It's definitely not the first of its kind to provide some
  support for this idea.  The earliest the author has found for
  a similar idea goes back to 2008 for the Racket language
  (`eli-tester`), but it seems unlikely that there were no
  other attempts.

  Niche is the fifth incarnation in a series of tools for Janet
  going back to 2020, starting with judge-gen.
  ``)

(def tutorial
  ``
  Tutorial
  ========

  This is a tutorial that introduces basics.  Please see the
  reference documentation for further details.

  Expressing Tests
  ----------------

  Create a file named `smile.janet` and put the following
  content in it:

    (comment

      (+ 1 2)
      # =>
      3

      )

  Some things to note:

  1. There is a surrounding `comment` form.

  2. There is an instance of `# =>` that indicates the presence
     of a test.

  3. The expression above `# =>` is intended to compute an
     "actual" value.

  4. The expression below `# =>` is intended to compute an
     "expected" value.

  So to express a test, put an expression to "test" which
  computes an "actual" value before another expression which is
  used to arrive at an expected value, and separate them by an
  instance of `# =>` on a line of its own.

  Some terminology:

  1. `# =>` is sometimes referred to as a "test indicator".
     It is modeled after sequences of characters sometimes used
     in various lisp communities to express "what comes before
     evaluates to what comes after".

  2. Expressions within the `comment` form may sometimes be
     referred to as "comment-hidden expressions".

  The use of the `comment` form means:

  1. The content doesn't really affect the meaning of existing
     code in a file according to `janet`.

  2. We can start writing tests without installing `niche`.
     Expressions can still be evaluated by "sending" them to a
     REPL, either via editor tooling or by copy-pasting.

  3. Your code doesn't gain any additional library dependencies,
     whether `niche` is installed or not.

  Using the `niche` tool
  ----------------------

  Re-evaluating things manually can get old pretty quickly
  though so obtaining `niche.janet` and putting or symlinking it
  on your `PATH` is recommended for convenience.

  To run the tests, pass the path of the file with the `comment`
  form in it to `niche`:

    $ niche.janet smile.janet

  or if you created a symlink to `niche.janet` named `niche`:

    $ niche smile.janet

  Interpreting `niche` output
  ---------------------------

  If all went well, the following sort of output should appear:

    smile.janet - [1/1]
    ===================================================
    All tests successful in 1 file(s).
    Total processing time was 0.00 secs.

  Try changing the expected value from `3` to `11` in
  `smile.janet` like:

    (comment

      (+ 1 2)
      # =>
      11

      )

  Now run `niche` again:

    $ niche smile.janet

  The output should look something like:

    smile.janet
    ---------------------------------------------------
    [1]

    failed:
    line 4

    form:
    (+ 1 2)

    expected:
    11

    actual:
    3
    ---------------------------------------------------
    [0/1]
    ===================================================
    Test failures in 1 of 1 file(s).
    Total processing time was 0.00 secs.

  It may be obvious but to spell things out a bit:

  * The "smile.janet" at the top indicates which file the
    immediately following information refers to.

  * There are two "dashed" separators (made up of the `-`
    character) that "bound" the failure results for
    "smile.janet".

  * The "[1]" indicates that what follows immediately is the
    first faliure in the file.

  * The "line 4" portion under "failed:" refers to where the
    test indicator (`# =>`) is in the file.  This can be useful
    information when navigating to the relevant code in the
    source file.

  * The "form:" portion labels what expression was evaluated to
    arrive at the actual value computed.

  * The "expected:" portion labels what value was expected.

  * The "actual:" portion labels what value was actually
    computed.

  * The "[0/1]" indicates that no tests passed out of a total of
    one test detected for the file.

  * The portions below the separator made up of `=` characters
    summarize the number of failures detected, the total number
    of associated files with failures, and the total processing
    time.

  There are some more details that were not covered such as:

  * Multiple test expressions can live in a single `comment`
    form.

  * Each `comment` can also contain non-test expressions.

  * A `comment` form that has no tests is ignored by `niche`.

  These and other details are covered in the reference
  documentation.
  ``)

(def reference
  ``
  Reference
  =========

  Anatomy of a Test
  -----------------

  Tests lives inside `comment` forms.  A simple example is:

    (comment

      (+ 1 2)
      # =>
      3

      )

  A general description might be:

    (comment

      <actual-value-expression>
      <test-indicator>
      <expected-value-expression>

      )

  `<actual-value-expression>` is used to compute an "actual"
  value.  The expression may span multiple lines.

  The result value is compared using `deep=` with the result
  of computing `<expected-value-expression>` (which may also
  span multiple lines).

  `<test-indicator>` is the sequence of characters `# =>`.
  (Some other sequences may work, but only `# =>` is intended
  for general consumption at the moment.)

  Each test indicator should live on a line of its own.  The
  line number that a test indicator is on is used to report
  failing tests.

  Some More Details
  -----------------

  * Multiple tests may appear within a single `comment` form.
    They are evaluated in order.

  * Forms that are not part of any test may also occur within
    `comment` forms.  These will also be evaluated in order
    but only if the containing `comment` form has at least one
    test in it.  This is done so that "ordinary" `comment`
    forms that existed prior to `niche`'s existence are not
    accidentally executed.

  * The expressions within `comment` forms that have tests in
    them are executed in order, interleaved with other
    non-comment expressions in the file.  There is no
    isolation between `comment` forms for the sake of
    simplicity.

  * Evaluation of expressions within `comment` forms with tests
    occur as if they were at the top-level.  That is, it is
    as if the wrapping of `(comment ...)` is removed and only
    `...` remains for evaluation.

  Limits on Expected Value Expressions
  ------------------------------------

  * Since expected value expressions get evaluated, if one
    wishes to express a tuple value, it is recommended to use
    either square bracket tuples or to quote paren tuples.
    Using just paren tuples will likely yield an inappropriate
    result because the expression will be treated as a call.

  * Only expressions that produce "readable" values are
    supported for actual value and expected value expressions.
    So expressions that produce non-readable values such as
    `printf` (which would yield `<cfunction printf>`) may
    appear to work sometimes, but not in all cases.

  * Since `deep=` is used to compare values, be careful when
    trying to compare dictionaries that have prototype values.
    The prototype information is not typically exposed as part
    of a dictionary's printed representation.  If desired,
    check prototype information using suitable expressions.

  Disabling Tests
  ---------------

  * Putting a space character between the `=` and `>` of a
    test indicator will disable the corresponding test.
    However, the associated actual and expected value
    expressions will still be evaluated.

  * Putting a space between the `(` and `c` characters for a
    `(comment ...)` form will prevent any of the expressions
    within the `comment` form from being executed.
  ``)

(defn choose-doc
  [doc-type]
  (get {:usage usage
        :reference reference
        :tutorial tutorial
        :background background}
       doc-type usage))

