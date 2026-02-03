(import ./args :as a)
(import ./commands :as c)
(import ./docs :as d)
(import ./errors :as e)
(import ./files :as f)
(import ./log :as l)
(import ./output :as o)

(def version "DEVEL")

(defn main
  [& args]
  (def start-time (os/clock))
  #
  (def opts (a/parse-args (drop 1 args)))
  #
  (when-let [htype (get opts :show-help)
             doc (d/choose-doc htype)]
    (l/noten :o doc)
    (os/exit 0))
  #
  (when (get opts :show-version)
    (l/noten :o version)
    (os/exit 0))
  #
  (when (not (get opts :includes))
    (l/noten :e "Nothing to operate on.")
    (os/exit 1))
  #
  (def src-paths
    (f/collect-paths (get opts :includes)
                     |(or (string/has-suffix? ".janet" $)
                          (f/has-janet-shebang? $))))
  (when (get opts :raw)
    (l/clear-d-tables!))
  # 0 - successful testing
  # 1 - at least one test failure
  # 2 - caught error
  (def [exit-code test-results]
    (try
      (c/make-run-report src-paths opts)
      ([e f]
        (l/noten :e)
        (if (dictionary? e)
          (e/show e)
          (debug/stacktrace f e "internal "))
        (l/noten :e "Processing halted.")
        [2 @[]])))
  #
  (if (get opts :raw)
    (print (o/color-form test-results))
    (l/notenf :i "Total processing time was %.02f secs."
              (- (os/clock) start-time)))
  #
  (when (not (get opts :no-exit))
    (os/exit exit-code)))

