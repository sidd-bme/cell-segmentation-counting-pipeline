// Batch count cells from Cellpose flow images.
// Mirrors manual steps:
// 1) convert flow image to 8-bit
// 2) auto-threshold
// 3) apply to binary mask
// 4) Analyze Particles
//
// Run example:
// ImageJ --headless --console -macro batch_count_flows.ijm \
// "input=/path/to/flows,output=/path/to/counts.csv,min_size=20"

arg = getArgument();
inputDir = "";
outputCsv = "";
minSize = "0";

if (arg == "") {
    // GUI mode: ask user for paths.
    inputDir = getDirectory("Choose folder with *_flows_cp_masks.tif");
    if (inputDir == "") exit("input folder is required");

    outputDir = getDirectory("Choose output folder for CSV");
    if (outputDir == "") exit("output folder is required");
    outName = getString("CSV file name", "counts_from_flows_fiji.csv");
    if (outName == "") exit("output CSV file name is required");
    outputCsv = outputDir + outName;

    minSizeVal = getNumber("Minimum particle size", 0);
    minSize = "" + minSizeVal;
} else {
    // CLI/headless mode: parse input=...,output=...,min_size=...
    parts = split(arg, ",");
    for (i = 0; i < parts.length; i++) {
        kv = split(parts[i], "=");
        if (lengthOf(kv) == 2) {
            key = trim(kv[0]);
            val = trim(kv[1]);
            if (key == "input") inputDir = val;
            if (key == "output") outputCsv = val;
            if (key == "min_size") minSize = val;
        }
    }
    if (inputDir == "") exit("input folder is required");
    if (outputCsv == "") outputCsv = inputDir + "counts_from_flows_fiji.csv";
}

if (!endsWith(inputDir, "/")) inputDir = inputDir + "/";
File.delete(outputCsv);
File.append("image,count,flow_file\n", outputCsv);

list = getFileList(inputDir);
setBatchMode(true);

for (i = 0; i < list.length; i++) {
    name = list[i];
    if (endsWith(name, "_flows_cp_masks.tif")) {
        open(inputDir + name);
        run("8-bit");
        setAutoThreshold("Default");
        run("Convert to Mask");
        run("Analyze Particles...", "size=" + minSize + "-Infinity show=Nothing clear");
        count = nResults;
        imageName = replace(name, "_flows_cp_masks.tif", "");
        File.append(imageName + "," + count + "," + name + "\n", outputCsv);

        if (isOpen("Results")) {
            selectWindow("Results");
            run("Close");
        }
        close();
    }
}

setBatchMode(false);
print("Saved counts CSV: " + outputCsv);
