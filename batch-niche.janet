(def repos-root "./repos")

(defn print-boundary
  [&opt len]
  (default len 60)
  (print (string/repeat "=" len)))

(defn tally-ecodes
  [results]
  (def by-ecode @{})
  #
  (each [proj-name ecode] results
    (def ps (get by-ecode ecode @[]))
    (put by-ecode ecode ps)
    (array/push ps proj-name))
  #
  by-ecode)

(defn print-ecodes
  [by-ecode]
  (each ecode (sort (keys by-ecode))
    (print "exit-code: " ecode)
    (each p (sort (get by-ecode ecode))
      (print " " p))))

########################################################################

(def proj-dirs
  (os/dir repos-root))

(def dir (os/cwd))

(def niche-path (os/realpath "niche.janet"))

(def results @[])

(def start-time (os/clock))

# run niche for each project and collect exit codes, etc.
(each proj-name (sort proj-dirs)
  (defer (os/cd dir)
    (def proj-dir (string repos-root "/" proj-name))
    (when (= :directory (os/stat proj-dir :mode))
      (os/cd proj-dir)
      (pp (string repos-root "/" proj-name))
      (def ecode (os/execute [niche-path] :p))
      (array/push results [proj-name ecode]))))

(print-boundary)

(def by-ecode (tally-ecodes results))

# display exit codes
(print-ecodes by-ecode)

(print-boundary)

(printf "Total project(s): %d" (length proj-dirs))
(printf "Total processing time: %.02f secs" (- (os/clock) start-time))

