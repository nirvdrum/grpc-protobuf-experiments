<?php

set_include_path(get_include_path() . PATH_SEPARATOR . dirname(__FILE__) . '/gen');

require_once 'vendor/autoload.php';

require_once 'GPBMetadata/Simple.php'; // Update to actual path
require_once 'Proto/Leak/Recursive.php'; // Update to actual path

function memsize_rss_bytes() {
  # busybox (docker) doesn't support very many ps args.
  $rss = shell_exec("ps -o pid,rss | awk -v PID=" . getmypid() . " '$1 == PID { print $2 }'");
  $int = intval($rss);
  // Not sure what values are possible in this env.
  if (preg_match("/^\d+m$/", $rss)) {
    $int *= 1_000_000;
  } elseif (preg_match("/^\d+k$/", $rss)) {
    $int *= 1_000;
  } else {
    print("WARNING, unknown unit: " . $rss. "\n");
    return null;
  }
  return $int;
}

$datum = new Proto\Leak\Recursive(); // Adjust class paths based on actual PHP namespaces

$memsize_rss_start = memsize_rss_bytes();
$memsize_rss_current = $memsize_rss_start;

$data = [];
for ($i = 0; $i < 10; $i++) {
    for ($j = 0; $j < 1000000; $j++) {
        $obj = new Proto\Leak\Recursive(['data' => [$datum]]);
    }

    // Trigger garbage collection
    gc_collect_cycles();
    $memsize_rss_current = memsize_rss_bytes();

    /* if (!empty(getenv('VERBOSE'))) { */
        $currentMemSize = memory_get_usage();
        echo "Memory usage: {$memsize_rss_current} - php space " . $currentMemSize .
             " diff " . ($memsize_rss_current - $currentMemSize) . PHP_EOL;
    /* } */
}

echo "Total memory growth: " . ($memsize_rss_current - $memsize_rss_start) . " KB" . PHP_EOL;
?>
