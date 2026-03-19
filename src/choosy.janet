(defn substr
  [src bl bc el ec &opt pos line]
  (default pos 0)
  (default line 0)
  #
  (def src-len (length src))
  (var cur-pos pos)
  (var cur-line line)
  (while (< cur-pos src-len)
    (when (= cur-line bl)
      (break))
    #
    (when (= (chr "\n") (get src cur-pos))
      (++ cur-line))
    (++ cur-pos))
  #
  (var cur-col 0)
  (while (<= cur-col bc)
    (when (= cur-col bc)
      (break))
    #
    (when (= (chr "\n") (get src cur-pos))
      (errorf "unexpected newline at position: %d" cur-pos))
    #
    (++ cur-pos)
    (++ cur-col))
  #
  (def start-pos cur-pos)
  #
  (while (< cur-pos src-len)
    (when (= cur-line el)
      (break))
    #
    (when (= (chr "\n") (get src cur-pos))
      (++ cur-line))
    (++ cur-pos))
  #
  (when (not= bl el)
    (set cur-col 0))
  (while (<= cur-col ec)
    (when (= cur-col ec)
      (break))
    #
    (when (= (chr "\n") (get src cur-pos))
      (errorf "unexpected newline at position: %d" cur-pos))
    #
    (++ cur-pos)
    (++ cur-col))
  #
  (def end-pos cur-pos)
  #
  [(string/slice src (- start-pos bc) start-pos)
   (string/slice src start-pos end-pos)
   cur-pos cur-line cur-col])

(defn try-next-slice
  [src pos line args idx]
  (assertf (<= 4 (- (length args) idx))
           "need more arguments: %n" args)
  #
  (def [bl bc el ec]
    (map scan-number (slice args idx (+ idx 4))))
  (assertf (all int? [bl bc el ec])
           "expected integers, but apparently not: %n" [bl bc el ec])
  (assertf (<= bl el)
           "first line should be <= second line, but: %d %d" bl el)
  (when (= bl el)
    (assertf (< bc ec)
             "start col should be < end col since on same line: %d %d"
             bc ec))
  #
  (def [indent-str target new-pos new-line _]
    (substr src bl bc el ec pos line))
  #
  [indent-str target new-pos new-line])

(defn process-slices
  [src args &opt start-idx]
  (default start-idx 1)
  (var idx start-idx)
  (var pos 0)
  (var line 0)
  (assertf (<= 4 (- (length args) idx))
           "need more arguments: %n" args)
  #
  (def results @[])
  #
  (while (<= 4 (- (length args) idx))
    (def [indent-str target new-pos new-line _]
      (try-next-slice src pos line args idx))
    #
    (array/push results [indent-str target])
    #
    (set pos new-pos)
    (set line new-line)
    (+= idx 4))
  #
  results)

(comment

  (def src
    ``
    (def my-fn
      [x]
      (+ x 2))

    # hello there

    (def k 11)
    ``)

  (process-slices src
                  (map string [0 0 2 10
                               6 0 6 10])
                  0)
  # =>
  @[["" "(def my-fn\n  [x]\n  (+ x 2))"]
    ["" "(def k 11)"]]

  )

(defn main
  [_ & args]
  (def fname (get args 0))
  (assertf (and fname (= :file (os/stat fname :mode)))
           "expected file, but %s isn't" fname)
  # XXX: going to assume file is not too big
  (def src (slurp fname))
  #
  (def results (process-slices src args))
  #
  (each [indent-str target] results
    (print indent-str target)))

