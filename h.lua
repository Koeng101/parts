dnadesign = require("dnadesign")
transform = dnadesign.transform
codon = dnadesign.codon
fix = dnadesign.fix
fragment = dnadesign.fragment
orthoprimers = dnadesign.orthoprimers
seqhash = dnadesign.seqhash
clone = dnadesign.clone

local function parse_frontmatter(content)
    local data = {}
    local in_frontmatter = false

    for line in content:gmatch("[^\r\n]+") do
        if line == "---" then
            if in_frontmatter then break end
            in_frontmatter = true
        elseif in_frontmatter then
            local key, value = line:match("^([^:]+):%s*(.*)$")
            if key and value then
                data[key:match("^%s*(.-)%s*$")] = value:match("^%s*(.-)%s*$")
            end
        end
    end
    return data
end

local function read_file(path)
    local file = io.open(path, "r")
    if not file then return nil end
    local content = file:read("*all")
    file:close()
    return content
end

local function scan_parts_dir()
    local results = {}
    local handle = io.popen("find ./parts -name '*.md' 2>/dev/null")

    for filepath in handle:lines() do
        local content = read_file(filepath)
        if content then
            local data = parse_frontmatter(content)
            if next(data) then
                results[filepath] = data
            end
        end
    end
    handle:close()
    return results
end

local function parse_tsv(filepath)
    local content = read_file(filepath)
    if not content then return {} end
    
    local data = {}
    local lines = {}
    for line in content:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    
    for i = 2, #lines do -- skip header
        local gene, sequence = lines[i]:match("^([^\t]+)\t(.*)$")
        if gene and sequence then
            local s = string.match(sequence, "^%s*(.-)%s*$")
            data[gene] = s
        end
    end
    return data
end

primers = {
    "CCGTGCGACAAGATTTCAAG",
    "CCTTTAACAGGACATGCAGC",
    "CGAACGCAAAAGTCCTCAAG",
    "CGATAGAACGACCAGGTAGC",
    "CGGATCGAACTTAGGTAGCC",
    "CGGGAGGAAGTCTTTAGACC",
    "CTAATATCCCTGAGCGACGG",
    "CTAGGGAACCAGGCTTAACG",
    "CTAGGGGATGGTCCAATACG",
    "CTATAGAATCCGGGCTGGTC",
    "CTGCTAGGGGCTACTTATCG",
    "GAAAAGTCCCAATGAGTGCC",
    "GAAGTGGTTTGCCTAAACGC",
    "GACCATGCAAGGAGAGGTAC",
    "GATACATAGACTTGGCCCCG",
    "GCACGCAAAAGGACATAACC",
    "GCAGCGTTTTAGCCTACAAG",
    "GCATAAAGTTGACAGGCCAG",
    "GCTAAATAGAGGGAAGCCCC",
    "GGAAAACTAAGACAAGGCGC",
    "GGAAACAATAACCATCGGCG",
    "GGGCACCGATTAAGAAATGC",
    "GGGTTGTCTCCTCTGATAGC",
    "GTACTCAGAGATTGCCGGAG",
    "GTATAAGATCAGCCGGACCC",
    "GTATGTCGGCTCTCGTATCG",
    "GTTCAGAGGTACGAACCCTC",
    "GTTGCATCTAAGCCAAGTGC",
    "TAAAGAGAGGGCGTCCAATC",
    "TAACGACGTGCCGAACTTAG",
    "TAAGATAGCACCACGGATGG",
    "TAAGGATTCATCAGGTGCGC",
    "TAAGGGACGATGCTTAACCC",
    "TACCACGAAATGCACAGGAG",
    "TACTGATAATTCGGACGCCC",
    "TACTTGAATACCACGTGGCC",
    "TAGCCAGGCAAAAGAGATCC",
    "TAGCTCGATAATCAAGGGGC",
    "TAGTGACCTAATGCCATGGG",
    "TAGTTGAGAACACGAACCCG",
    "TATAACAGGCTGCTGAGACC",
    "TATACTGAAGAACGGCCCAG",
    "TATCAATCCGGAACCAGTGC",
    "TATCACGGAAGGACTCAACG",
    "TCAAAGGAGCACGAACCTAC",
    "TCAAGGTCCGTTATGGAACC",
    "TCACATAGAAGGACATGGCG",
    "TCACTTGGTATCGAGAACGG"
}

local vector = {
            sequence = "TAACTATCGTCTTGAGTCCAACCCGGTAAGACACGACTTATCGCCACTGGCAGCAGCCACTGGTAACAGGATTAGCAGAGCGAGGTATGTAGGCGGTGCTACAGAGTTCTTGAAGTGGTGGCCTAACTACGGCTACACTAGAAGAACAGTATTTGGTATCTGCGCTCTGCTGAAGCCAGTTACCTTCGGAAAAAGAGTTGGTAGCTCTTGATCCGGCAAACAAACCACCGCTGGTAGCGGTGGTTTTTTTGTTTGCAAGCAGCAGATTACGCGCAGAAAAAAAGGATCTCAAGAAGGCCTACTATTAGCAACAACGATCCTTTGATCTTTTCTACGGGGTCTGACGCTCAGTGGAACGAAAACTCACGTTAAGGGATTTTGGTCATGAGATTATCAAAAAGGATCTTCACCTAGATCCTTTTAAATTAAAAATGAAGTTTTAAATCAATCTAAAGTATATATGAGTAAACTTGGTCTGACAGTTACCAATGCTTAATCAGTGAGGCACCTATCTCAGCGATCTGTCTATTTCGTTCATCCATAGTTGCCTGACTCCCCGTCGTGTAGATAACTACGATACGGGAGGGCTTACCATCTGGCCCCAGTGCTGCAATGATACCGCGAGAACCACGCTCACCGGCTCCAGATTTATCAGCAATAAACCAGCCAGCCGGAAGGGCCGAGCGCAGAAGTGGTCCTGCAACTTTATCCGCCTCCATCCAGTCTATTAATTGTTGCCGGGAAGCTAGAGTAAGTAGTTCGCCAGTTAATAGTTTGCGCAACGTTGTTGCCATTGCTACAGGCATCGTGGTGTCACGCTCGTCGTTTGGTATGGCTTCATTCAGCTCCGGTTCCCAACGATCAAGGCGAGTTACATGATCCCCCATGTTGTGCAAAAAAGCGGTTAGCTCCTTCGGTCCTCCGATCGTTGTCAGAAGTAAGTTGGCCGCAGTGTTATCACTCATGGTTATGGCAGCACTGCATAATTCTCTTACTGTCATGCCATCCGTAAGATGCTTTTCTGTGACTGGTGAGTACTCAACCAAGTCATTCTGAGAATAGTGTATGCGGCGACCGAGTTGCTCTTGCCCGGCGTCAATACGGGATAATACCGCGCCACATAGCAGAACTTTAAAAGTGCTCATCATTGGAAAACGTTCTTCGGGGCGAAAACTCTCAAGGATCTTACCGCTGTTGAGATCCAGTTCGATGTAACCCACTCGTGCACCCAACTGATCTTCAGCATCTTTTACTTTCACCAGCGTTTCTGGGTGAGCAAAAACAGGAAGGCAAAATGCCGCAAAAAAGGGAATAAGGGCGACACGGAAATGTTGAATACTCATACTCTTCCTTTTTCAATATTATTGAAGCATTTATCAGGGTTATTGTCTCATGAGCGGATACATATTTGAATGTATTTAGAAAAATAAACAAATAGGGGTTCCGCGCACCTGCACCAGTCAGTAAAACGACGGCCAGTAGTCAAAAGCCTCCGACCGGAGGCTTTTGACTTGGTTCAGGTGGAGTGGGAGTAgtcttcGCcatcgCtACTAAAagccagataacagtatgcgtatttgcgcgctgatttttgcggtataagaatatatactgatatgtatacccgaagtatgtcaaaaagaggtatgctatgaagcagcgtattacagtgacagttgacagcgacagctatcagttgctcaaggcatatatgatgtcaatatctccggtctggtaagcacaaccatgcagaatgaagcccgtcgtctgcgtgccgaacgctggaaagcggaaaatcaggaagggatggctgaggtcgcccggtttattgaaatgaacggctcttttgctgacgagaacagggGCTGGTGAAATGCAGTTTAAGGTTTACACCTATAAAAGAGAGAGCCGTTATCGTCTGTTTGTGGATGTACAGAGTGATATTATTGACACGCCCGGGCGACGGATGGTGATCCCCCTGGCCAGTGCACGTCTGCTGTCAGATAAAGTCTCCCGTGAACTTTACCCGGTGGTGCATATCGGGGATGAAAGCTGGCGCATGATGACCACCGATATGGCCAGTGTGCCGGTCTCCGTTATCGGGGAAGAAGTGGCTGATCTCAGCCACCGCGAAAATGACATCAAAAACGCCATTAACCTGATGTTCTGGGGAATATAAATGTCAGGCTCCCTTATACACAGgcgatgttgaagaccaCGCTGAGGTGTCAATCGTCGGAGCCGCTGAGCAATAACTAGCATAACCCCTTGGGGCCTCTAAACGGGTCTTGAGGGGTTTTTTGCATGGTCATAGCTGTTTCCTGAGAGCTTGGCAGGTGATGACACACATTAACAAATTTCGTGAGGAGTCTCCAGAAGAATGCCATTAATTTCCATAGGCTCCGCCCCCCTGACGAGCATCACAAAAATCGACGCTCAAGTCAGAGGTGGCGAAACCCGACAGGACTATAAAGATACCAGGCGTTTCCCCCTGGAAGCTCCCTCGTGCGCTCTCCTGTTCCGACCCTGCCGCTTACCGGATACCTGTCCGCCTTTCTCCCTTCGGGAAGCGTGGCGCTTTCTCATAGCTCACGCTGTAGGTATCTCAGTTCGGTGTAGGTCGTTCGCTCCAAGCTGGGCTGTGTGCACGAACCCCCCGTTCAGCCCGACCGCTGCGCCTTATCCGG",
            circular = true
        }

local natto_vector = {
    sequence = "GAATGGCCATGACCAAAATCCCTTAACGTGAGTTTTCGTTCCACTGAGCGTCAGACCCCGTAGAAAAGATCAAAGGATCTTCTTGAGATCCTTTTTTTCTGCGCGTAATCTGCTGCTTGCAAACAAAAAAACCACCGCTACCAGCGGTGGTTTGTTTGCCGGATCAAGAGCTACCAACTCTTTTTCCGAAGGTAACTGGCTTCAGCAGAGCGCAGATACCAAATACTGTCCTTCTAGTGTAGCCGTAGTTAGGCCACCACTTCAAGAACTCTGTAGCACCGCCTACATACCTCGCTCTGCTAATCCTGTTACCAGTGGCTGCTGCCAGTGGCGATAAGTCGTGTCTTACCGGGTTGGACTCAAGACGATAGTTACCGGATAAGGCGCAGCGGTCGGGCTGAACGGGGGGTTCGTGCACACAGCCCAGCTTGGAGCGAACGACCTACACCGAACTGAGATACCTACAGCGTGAGCTATGAGAAAGCGCCACGCTTCCCGAAGGGAGAAAGGCGGACAGGTATCCGGTAAGCGGCAGGGTCGGAACAGGAGAGCGCACGAGGGAGCTTCCAGGGGGAAACGCCTGGTATCTTTATAGTCCTGTCGGGTTTCGCCACCTCTGACTTGAGCGTCGATTTTTGTGATGCTCGTCAGGGGGGCGGAGCCTATGGAAAAACGCCAGCAACGCGGCCTTTTTACGGTTCCTGGCCTTTTGCTGGCCTTTTGCTCACATGTTCTTTCCTGCGTTATCCCCTGATTCTGTGGATAACCGTATTACCGCCTTTGAGTGAGCTGAAATTATGAGGGGATCTCTCAGAGCTCGAGGTCATCGTTCAAAATGGTATGCGTTTTGACACATCCACTATATATCCGTGTCGTTCTGTCCACTCCTGAATCCCATTCCAGAAATTCTCTAGCGATTCCAGAAGTTTCTCAGAGTCGGAAAGTTGACCAGACATTACGAACTGGCACAGATGGTCATAACCTGAAGGAAGATCTGATTGCTTAACTGCTTCAGTTAAGACCGAAGCGCTCGTCGTATAACAGATGCGATGATGCAGACCAATCAACATGGCACCTGCCATTGCTACCTGCACAGTCAAGGATGGTAGAAATGTTGTCGGTCCTTGCACACGAATATTACGCCATTTGCCTGCATATTCAAACAGCTCTTCTACGATAAGGGCACAAATCGCATCGTGGAACGTTTGGGCTTCTACCGATTTAGCAGTTTGATACACTTTCTCTAAGTATCCACCTGAATCATAAATCGGCAAAATAGAGAAAAATTGACCATGTGTAAGCGGCCAATCTGATTCCACCTGAGATGCATAATCTAGTAGAATCTCTTCGCTATCAAAATTCACTTCCACCTTCCACTCACCGGTTGTCCATTCATGGCTGAACTCTGCTTCCTCTGTTGACATGACACACATCATCTCAATATCCGAATAGGGCCCATCAGTCTGACGACCAAGAGAGCCATAAACACCAATAGCCTTAACATCATCCCCATATTTATCCAATATTCGTTCCTTAATTTCATGAACAATCTTCATTCTTTCTTCTCTAGTCATTATTATTGGTCCATTCACTATTCTCATTCCCTTTTCAGATAATTTTAGATTTGCTTTTCTAAATAAGAATATTTGGAGAGCACCGTTCTTATTCAGCTATTAAACCCATTATATCGGGTTTTTGAGGGGATTTCAACTGCAGACACCTAAATTCAAAATCTATCGGTCAGATTTATACCGATTTGATTTTATATATTCTTGAATAACATACGCCGAGTTATCACATAAAAGCGGGAACCAATCATCAAATTTAAACTTCATTGCATAATCCATTAAACTCTTAAATTCTACGATTCCTTGTTCATCAATAAACTCAATCATTTCTTTAATTAATTTATATCTATCTGTTGTTGTTTTCTTTAATAATTCATCAACATCTACACCGCCATAAACTATCATATCTTCTTTTTGATATTTAAATTTATTAGGATCGTCCATGTGAAGCATATATCTCACAAGACCTTTCACACTTCCTGCAATCTGCGGAATAGTCGCATTCAATTCTTCTGTTAATTATTTTTATCTGTTCATAAGATTTATTACCCTCATACATCACTAGAATATGATAATGCTCTTTTTTCATCCTACCTTCTGTATCAGTATCCCTATCATGTAATGGAGACACTACAAATTGAATGTGTAACTCTTTTAAATACTCTAACCACTCGGCTTTTGCTGATTCTGGATATAAAACAAATGTCCAATTACGTCCTCTTGAATTTTTCTTGTTTTCAGTTTCTTTTATTACATTTTCGCTCATGATATAATAACGGTGCTAATACATTTAACAAAATTTAGTCATAGATAGGCAGCATGCCAGTGCTGTCTATCTTTTTTTGTTTAAAATGCACCGTATTCCTCCTTTGCATATTTTTTTATTAGAATACCGGTTGCATCTGATTTGCTAATATTATATTTTTCTTTGATTCTATTTAATATCTCATTTTCTTCTGTTGTAAGTCTTAAAGTAACAGCAACTTTTTTCTCTTCTTTTCTATCTACAACCATCACTGTACCTCCCAACATCTGTTTTTTTCACTTTAACATAAAAAACAACCTTTTAACATTAAAAACCCAATATTTATTTATTTGTTTGGACAATGGACAATGGACACCTAGGGGGGAGGTCGTAGTACCCCCCTATGTTTTCTCCCCTAAATAACCCCAAAAATCTAAGAAAAAAAGACCTCAAAAAGGTCTTTAATTAACATCTCAAATTTCGCATTTATTCCAATTTCCTTTTTGCGTGTGATGCGAATTCTTGACCGTGATTAGAGAATTGAGTAAAATGTACCtacggttaacgttaatctttacgagttttagagctagaaatagcaagttaaaataaggctagtccgttatcaacttgaaaaagtggcaccgagtcggtgctttttactccatctggatttgttcagaacgctcggttgccgccgggcgttttttatctaaagcttaggcccagtcgaaagactgggcctttttaatacgactcactatagggtcgacccctctcggcaaatgtgccgggagggttctttgcgtttggccaacgaggttaggcatagcttgtcgcgatcacctcatccccctccgcaaaacgcggatcattggaagagacgaccgtacccgcagcatcaatgcctaaaataagtggatactctctgacgatattgcctcctgcttttccggccagaccatctttgtaattgatgccggaataagcaactttaatcaggacaccatccttaggcaaatcctctgttgatatggttttcacatggactgaaacatcatcggcatttttttctgcctgcaatgcttgaaataacgttgacattcggcacactccttttcatttatatcgtaaccgaagaacgttcaaaaaaccaaatcatcaagctgccattttcacttcgccggcacattgagagaataatggacaaatccggtatcctcttcatagccgttttgctcatacaagcttcttgccttcctgttgtggtgctcagtctgaagcgttaaacattttgccccgttttcccctgcataatcctttgcggcagaaagtagccggccgcccgctccctttgtacgagcataaggagcgacaaataagtcatttaatatgtagatccttttcattgacacagaagaaaacgttggatagagctgggtaaaacctatgaattctccattttcttctgctgtcaaaataacagactcatgattttccaaacgagctttcaaaaaagcctccgccccttgcaaatcggatgcctgtctataaaattcccgatattggttaaacagcggcgcgagggctgctgcatctgatgtctttgcttggcgaatgttcatctcatttcttcctccctctcaataaattttttcattctatccctaatcgaattttctgtaaagtttattttccagaatacttttatcatcatgcattgaaaaaagatcacgataatatcaattgttctcacggaagcatatgcaggtcattcgaacgaattttttcgacaggaatttgccgggactcaggagcatttaaaaaaagctgtgcggctcaatgagccgcacagctttttttaTTATTTGCTATTGGAGCTTGAGGATGATGTGCTGTTTGACGTGCTACTCGTGTTGAATGTATCTTTCAAATCCTTGTCTTTAACTTCAATATCAGCTTTTTTCATCACTTTCTGAACGGCTTCTTGAACAGCTGCGTTATCATTCAGCTTTTGCTCCAGTACCTCCGATTTCAGCTCTTTTTTCATATCATCATACTTTCCGCGTTCTTCCGTCTTTTTGATAATGTGATATCCGTACTGTGTCTTGACCGGATCAGACACTTCACCTGTTTTTAATTTGAATGCTGCTTTTGAAAATGTCTCATCCATTTGTCCCTCCTTCGCGAACCATCCCAGATCCCCGCCTTTGCTAGCGGATGAATCAGTAGAATACTCTTTGGCCAAATCCTCGAATTTTTCACCTTTTTTTAATTTTTTTTCAACCTCTTCAGCGGTCTTTTTGTCAGCTACCAGGATATGACTTGCTCTAATTTTCCCCTTCAATCCTTCCCAATATTCTTTGATGTCAGCGTCGGTTACTTTAATATTATCCTTCGCAGCTTTTTGTGTCAAAAGTTCATACTTAACTTGTTCTTTAAGATAATCTTTACCGTATTGTTTCTCCAGGGCCGTGTATTGGTCGCCCAGTTGCGTTTTGTATTCTTTCAGCTTATTGTCTATTTCCTTATCGCTGACCTTGTATTTTTTATCCAACACTTTTTCCTGCACCAGCTGTGTAAGGACGCTAGCTCCAGCTGTTTTCTTCATGTTAGTGTACAGCTCACCCTTAGTTACATCACCAGCATCGGTTTTTGCTATTACTTCTTTATCGCCTGATGAACAAGCTGATAAGGCCAGGATGCTTGTCGCCGTAATTGCAGCAATAGCAATTTTCTTCATtgttttcaaacactcctaatcattccaaattaaattcctaTGAGACCtactaaaagccagataacagtatgcgtatttgcgcgctgatttttgcggtataagaatatatactgatatgtatacccgaagtatgtcaaaaagaggtatgctatgaagcagcgtattacagtgacagttgacagcgacagctatcagttgctcaaggcatatatgatgtcaatatctccggtctggtaagcacaaccatgcagaatgaagcccgtcgtctgcgtgccgaacgctggaaagcggaaaatcaggaagggatggctgaggtcgcccggtttattgaaatgaacggctcttttgctgacgagaacaggggctggtgaaatgcagtttaaggtttacacctataaaagagagagccgttatcgtctgtttgtggatgtacagagtgatattattgacacgcccggtcgacggatggtgatccccctggccagtgcacgtctgctgtcagataaagtctcccgtgaactttacccggtggtgcatatcggggatgaaagctggcgcatgatgaccaccgatatggccagtgtgccggtTtccgttatcggggaagaagtggctgatctcagccaccgcgaaaatgacatcaaaaacgccattaacctgatgttctggggaatataaatgtcaggcacagGGTCTCTgctggaaaaagcagtacagaaaagaaatacattgtcggatttaagcagacaatgagtgccatgagttccgccaagaaaaaggatgttatttctgaaaaaggcggaaaggttcaaaagcaatttaagtatgttaacgcggccgcagcaacattggatgaaaaagctgtaaaagaattgaaaaaagatccgagcgttgcatatgtggaagaagatcatattAcacatgaatatgcgcaatctgttccttatggcatttctcaaattaaagcgccggctcttcactctcaaggctacacaggctctaacgtaaaagtagctgttatcgacagcggaattgactcttctcatcctgacttaaacgtcagaggcggagcaagcttcgttccttctgaaacaaacccataccaggacggcagttctcacggtacgcatgtcgccggtacgattgccgctcttaataactcaatcggtgttctgggcgtagcgccaagcgcatcattatatgcagtaaaagtgcttgattcaacaggaagcggccaatatagctggattattaacggcattgagtgggccatttccaacaatatggatgttatcaacatgagccttggcggacctactggttctacagcgctgaaaacagtagttgataaagcggtttccagcggtatcgtcgttgctgccgcagccggaaacgaaggttcatccggaagcacaagcacagtcggctaccctgcaaaatatccttctactattgcagtaggtgcggtaaacagcagcaaccaaagagcttcattctccagcgtaggttctgagcttgatgtaatggctcctggcgtgtccatccaaagcacacttcctggaggcacttacggcgcttataacggaacgtccatggcgactcctcacgttgccggagcagcagcgctaattctttctaagcacccgacttggacaaacgcgcaagtccgtgatcgtttagaaagcactgcaacatatctacggccagcctcgcagagcaggattcccgttgagcaccgccaggtgcgaataagggacagtgaagaaggaacacccgctcgcgggtgggcctacttcacctatcctgcccggctgacgccgttggatacaccaaggaaagtctacacgaaccctttggcaaaatcctgtatatcgtgcgaaaaaggatggatataccgaaaaaatcgctataatgaccccgaagcagggttatgcagcggaaaagCTAGATTAAGAAATAATCTTCATCTAAAATATACTTCAGTCACCTCCTAGCTGACTCAAATCAATGCGTGTTTCATAAAGACCAGTGATGGATTGATGGATAAGAGTGGCATCTAAAACTTCTTTTGTAGACGTATATCGTTTACGATCAATTGTTGTATCAAAATATTTAAAAGCAGCGGGAGCTCCAAGATTCGTCAACGTAAATAAATGAATAATATTTTCTGCTTGTTCACGTATTGGTTTGTCTCTATGTTTGTTATATGCACTAAGAACTTTATCTAAATTGGCATCTGCTAAAATAACACGCTTAGAAAATTCACTGATTTGCTCAATAATCTCATCTAAATAATGCTTATGCTGCTCCACAAACAATTGTTTTTGTTCGTTATCTTCTGGACTACCCTTCAACTTTTCATAATGACTAGCTAAATATAAAAAATTCACATATTTGCTTGGCAGAGCCAGCTCATTTCCTTTTTGTAATTCTCCGGCACTAGCCAGCATCCGTTTACGACCGTTTTCTAACTCAAAAAGACTATATTTAGGTAGTTTAATGATTAAGTCTTTTTTAACTTCCTTATATCCTTTAGCTTCTAAAAAGTCAATCGGATTTTTTTCAAAGGAACTTCTTTCCATAATTGTGATCCCTAGTAACTCTTTAACGGATTTTAACTTCTTCGATTTCCCTTTTTCCACCTTAGCAACCACTAGGACTGAATAAGCTACCGTTGGACTATCAAAACCACCATATTTTTTTGGATCCCAGTCTTTTTTACGAGCAATAAGCTTGTCCGAATTTCTTTTTGGTAAAATTGACTCCTTGGAGAATCCGCCTGTCTGTACTTCTGTTTTCTTGACAATATTGACTTGGGGCATGGACAATACTTTGCGCACTGTGGCAAAATCTCGCCCTTTATCCCAGACAATTTCTCCAGTTTCCCCATTAGTTTCGATTAGAGGGCGTTTGCGAATCTCTCCATTTGCAAGTGTAATTTCTGTTTTGAAGAAGTTCATGATATTAGAGTAAAAGAAATATTTTGCGGTTGCTTTGCCTATTTCTTGCTCAGACTTAGCAATCATTTTACGAACATCATAAACTTTATAATCACCATAGACAAACTCCGATTCAAGTTTTGGATATTTCTTAATCAAAGCAGTTCCAACGACGGCATTTAGATACGCATCATGGGCATGATGGTAATTGTTAATCTCACGTACTTTATAGAATTGGAAATCTTTTCGGAAGTCAGAAACTAATTTAGATTTTAAGGTAATCACTTTAACCTCTCGAATAAGTTTATCATTTTCATCGTATTTAGTATTCATGCGACTATCCAAAATTTGTGCCACATGCTTAGTGATTTGGCGAGTTTCAACCAATTGGCGTTTGATAAAACCAGCTTTATCAAGTTCACTCAAACCTCCACGTTCAGCTTTCGTTAAATTATCAAACTTACGTTGAGTGATTAACTTGGCGTTTAGAAGTTGTCTCCAATAGTTTTTCATCTTTTTGACTACTTCTTCACTTGGAACGTTATCCGATTTACCACGATTTTTATCAGAACGCGTTAAGACCTTATTGTCTATTGAATCGTCTTTAAGGAAACTTTGTGGAACAATGTGATCGACATCATAATCACTTAAACGATTAATATCTAATTCTTGGTCCACATACATGTCTCTTCCATTTTGGAGATAATAGAGATAGAGCTTTTCATTTTGCAATTGAGTATTTTCAACAGGATGCTCTTTAAGAATCTGACTTCCTAATTCTTTGATACCTTCTTCGATTCGTTTCATACGCTCTCGCGAATTTTTCTGGCCCTTTTGAGTTGTCTGATTTTCACGTGCCATTTCAATAACGATATTTTCTGGCTTATGCCGCCCCATTACTTTGACCAATTCATCAACAACTTTTACAGTCTGTAAAATACCTTTTTTAATAGCAGGGCTACCAGCTAAATTTGCAATATGTTCATGTAAACTATCGCCTTGTCCAGACACTTGTGCTTTTTGAATGTCTTCTTTAAATGTCAAACTATCATCATGGATCAGCTGCATAAAATTGCGATTGGCAAAACCATCTGATTTCAAAAAATCTAATATTGTTTTGCCAGATTGCTTATCCCTAATACCATTAATCAATTTTCGAGACAAACGTCCCCAACCAGTATAACGGCGACGTTTAAGCTGTTTCATCACCTTATCATCAAAGAGGTGAGCATATGTTTTAAGTCTTTCCTCAATCATCTCCCTATCTTCAAATAAGGTCAATGTTAAAACAATATCCTCTAAGATATCTTCATTTTCTTCATTATCCAAAAAATCTTTATCTTTAATAATTTTTAGCAAATCATGGTAGGTACCTAATGAAGCATTAAATCTATCTTCAACTCCTGAAATTTCAACACTATCAAAACATTCTATTTTTTTGAAATAATCTTCTTTTAATTGCTTAACGGTTACTTTTCGATTTGTTTTGAAGAGTAAATCAACAATGGCTTTCTTCTGTTCACCTGAAAGAAATGCTGGTTTTCGCATTCCTTCAGTAACATATTTGACCTTTGTCAATTCGTTATAAACCGTAAAATACTCATAAAGCAAACTATGTTTTGGTAGTACTTTTTCATTTGGAAGATTTTTATCAAAGTTTGTCATGCGTTCAATAAATGATTGAGCTGAAGCACCTTTATCGACAACTTCTTCAAAATTCCATGGGGTAATTGTTTCTTCAGACTTCCGAGTCATCCATGCAAAACGACTATTGCCACGCGCCAATGGACCAACATAATAAGGAATTCGAAAAGTCAAGATTTTTTCAATCTTCTCACGATTGTCTTTTAAAAATGGATAAAAGTCTTCTTGTCTTCTCAAAATAGCATGCAGCTCACCCAAGTGAATTTGATGGGGAATAGAGCCGTTGTCAAAGGTCCGTTGCTTGCGCAGCAAATCTTCACGATTTAGTTTCACCAATAATTCCTCAGTACCATCCATTTTTTCTAAAATTGGTTTGATAAATTTATAAAATTCTTCTTGGCTAGCTCCCCCATCAATATAACCTGCATATCCGTTTTTTGATTGATCAAAAAAGATTTCTTTATACTTTTCTGGAAGTTGTTGTCGAACTAAAGCTTTTAAAAGAGTCAAGTCTTGATGATGTTCATCGTAGCGTTTAATCATTGAAGCTGATAGGGGAGCCTTAGTTATTTCAGTATTTACTCTTAGGATATCTGAAAGTAAAATAGCATCTGATAAATTCTTAGCTGCCAAAAACAAATCAGCATATTGATCTCCAATTTGCGCCAATAAATTATCTAAATCATCATCGTAAGTATCTTTTGAAAGCTGTAATTTAGCATCTTCTGCCAAATCAAAATTTGATTTAAAATTAGGGGTCAAACCCAATGACAAAGCAATGAGATTCCCAAATAAGCCATTTTTCTTCTCACCGGGGAGCTGAGCAATGAGATTTTCTAATCGTCTTGATTTACTCAATCGTGCAGAAAGAATCGCTTTAGCATCTACTCCACTTGCGTTAATAGGGTTTTCTTCAAATAATTGATTGTAGGTTTGTACCAACTGGATAAATAGTTTGTCCACATCACTATTATCAGGATTTAAATCTCCCTCAATCAAAAAATGACCACGAAACTTAATCATATGCGCTAAGGCCAAATAGATTAAGCGCAAATCCGCTTTATCAGTAGAATCTACCAATTTTTTTCGCAGATGATAGATAGTTGGATATTTCTCATGATAAGCAACTTCATCTACTATATTTCCAAAAATAGGATGACGTTCATGCTTCTTGTCTTCTTCCACCAAAAAAGACTCTTCAAGTCGATGAAAGAAACTATCATCTACTTTCGCCATCTCATTTGAAAAAATCTCCTGTAGATAACAAATACGATTCTTCCGACGTGTATACCTTCTACGAGCTGTCCGTTTGAGACGAGTCGCTTCCGCTGTCTCTCCACTGTCAAATAAAAGAGCCCCTATAAGATTTTTTTTGATACTGTGGCGGTCTGTATTTCCCAGAACCTTGAACTTTTTAGACGGAACCTTATAATCATCAGTGATCACCGCCCATCCGACGCTATTTGTGCCGATATCTAAGCCTATTGAGTATTTCTTATCCATTTTTGCCTCCTAACTTAAGAATAAGATCTTGTCTCAACTGTATACCGAAATCAGCTCATTAAAATCGCTTTTTTTACCATAGGTTCCGGTAATAAAGGCATTTTTCCCTATAACAAAAAAAGCAAGGAATAATCCCTGCTTTTAATAATCCAAATGAGATAAAAATGTCATGACATTGGTGTACAGAA",
    circular = true
}

-- Promoters
local promoters = {
    P2069 = "ggatccgaattcagatctcctttgctgaagagggctttttttgtgccatcatcatctcatcaaacaggagaactgtctaatttgaaaaatgagatttttcaacgataaaaagtcatttttaacaaacatttcgacaaaatgagaaaaatagaaagagaaaaggagaggctgtaaatgcccaaaaatcggcaatggaagggttattgcgggataccgaaaactttacgaaaaacgacatttcatatttcttcgggttgacagtatatgatagaatattgtatactccagtaaaatttatcaaggaggaaaaaacatatg",
    P43 = "attttacatttttagaaatgggcgtgaaaaaaagcgcgcgattatgtaaaatataa",
    Pgrac100 = "agatctattggtagaccaaaggaggtaaggatcactagaaaattttttaaaaaatctcttgacattggaagggagatatgttattataagaattgcggaattgtgagcggataacaattcccatataaaggaggaaggacatatg",
    Phpaii = "gtcccttgctgatttttaaacgagcacgagagcaaaacccccctttgctgaggtggcagagggcaggtttttttgtttcttttttctcgtaaaaaaaagaaaggtcttaaaggttttatggttttggtcggcactgccgacagcctcgcagagcacacactttatgaatataaagtatagtgtgttatactttacttggaagtggttgccggaaagagcgaaaatgcctcacatttgtgc",
    Psdp4 = "CGACGCGTCGTGCCGAAGCCGTAAaaagttcccaaattcaattctgTCGAaacttttttaagtccaatccaaatggttgaatatcaaacttcaagaaaacaaacaaaataatgcataatttacattaatttattaattatccattttttgttgattattctgactagctattatataatctttttgaaatgattatattagcttagaggaggtaatcTACATCAAAA",
    PskfA = "agctcctgtttttctcgagaggatagcttgtcagcttttctatttttaaagggttaaaatattctatttatactaattaatgtaatttttaggataatatacaaaatcccccttacttcgacaattgcaatctggtattatcgtatcgcatgggagctatgtcaatagactctatgcaaa",
    PsrfA = "atcgacaaaaatgtcatgaaagaatcgttgtaagacgctcttcgcaagggtgtctttttttgcctttttttcggtttttgcgcggtacacatagtcatgtaaagattgtaaattgcattcagcaataaaaaaagattgaacgcagcagtttggtttaaaaattttttatttttctgtaaataatgtttagtggaaatgattgcggcatcccgcaaaaaatattgctgtaaataaactggaatctttcggcatcccgcatgaaacttttcacccatttttcggtgataaaaacatttttttcatttaaactgaacggtagaaagataaaagaataaatagccaaaattggtttcttattagggtggggtcttgcggtctttatccgcttatgttaaacgccgcaatgctgactgacggcagcctgctttaatagcggccatctgttttttgattggaagcactgctttttaagtgtagtactttgggctatttcggctgttagttcataagaattaaaagctgatatggataagaaagagaaaatgcgttgcacatgttcact",
    Pveg = "ggagttctgagaattggtatgccttataagtccaattaacagttgaaaacctgcataggagagctatgcgggttttttattttacataatgatacataatttaccgaaacttgcggaacataattgaggaatcatagaattttgtcaaaataattttattgacaacgtcttattaacgttgatataatttaaattttatttgacaaaaatgggctcgtgttgtacaataaatgtagt",
    PtrnQ = "ggatccgaattcagatctagattgccaattaagatgctttgtctatttaaaaaacggcctctcgaaatagagggttgttatttgaaaggaattatcgtataattagttgtgctagtaaaatttatcaaggaggaaaaaacatatg"
}

-- Signal peptides
local signal_peptides = {
    amyQ = "TGTATAAATTATTTATCTTGAAAGGAGGGATGCCTAAAAACGAAGAACATTAAAAACATATATTTGCACCGTCTAATGGATTTATGAAAAATCATTTTATCAGTTTGAAAATTATGTATTATGATTAACTAATAAGGAGGACAAACATGATTCAAAAACGAAAGCGGACAGTTTCGTTCAGACTTGTGCTTATGTGCACGCTGTTATTTGTCAGTTTGCCGATTACAAAAACATCAGCC",
    aprN = "agtcttttaagtaagtctactctgaattttttaaaaggagagggtaaagaatgagaagcaaaaaattgtggatcagcttgttgtttgcgttaacgCTGatTttCacTatggcgttcagcaacatgtctgcgcaggct",
    sacB = "acacagtacataaaaaaggagacatgaacgatgaacatcaaaaagtttgcaaaacaagcaacagtattaacctttactaccgcactgctggcaggaggcgcaactcaagcgtttgcg",
    sacC = "tcaaacatgaagagaggagcgaaggaacaaatgaaaaagagactgattcaagtcatgatcatgttcaccctgctgttgactatggcattttcggcagatgcagccg",
    wapA = "attacttttattacaaaaggagagaggaaatgaaaaaaagaaagaggcgaaactttaaaaggttcattgcagcatttttagtgttggctttaatgatttcattagtgccagccgatgtactagca",
    xynA = "agtcggaaaaaatattataggaggtaacatatgtttaagtttaaaaagaatttcttagttggattatcggcagctttaatgagtattagcttgttttcggcaaccgcctctgca",
    yncM = "atggcgaaaccactatcaaaagggggaattttggtgaaaaaagtattgattgcaggtgcagtaggaacagcagttcttttcggaaccctttcatcaggtataccaggtttacccgcggcagacgct",
    yojL = "tgcaaaaaaacagtttaggaggttgaatgaatgaaaaagaagattgtagccggcttggctgtttctgcagttgttgggtcgtcgatggccgcagcacccgcggaagca"
}

-- ========================================================================= --
--
--					Computational start
--
-- ========================================================================= --

opool = ""
twist_fragments = ""
clns = ""

ops = orthoprimers.new_default_orthogonal_primer_set()
libops = orthoprimers.new_orthogonal_primer_set(primers)
phiBT1_ga = "AATTACCAGGTTTTTGACGAAAGAGATCCAGATGATCCAGCTCCA"
phiBT1_tc = "GTGCTGAGTAGTTTCCCATGGATCGATGTCCAGAGAC"
p165 = "TTGACAGACAATCCGTAGGC"
p162 = "TTAGTAGGCAAGCATACCCG"
p158 = "TGCTGAATGAGAAACCTCGG"
p159 = "TGGGGACGACTTATAATGCC"

rseq = "ATGAACGAAGTCGAGCGTGGACAAAACAATGCGGGTATTGTCGAATATCAGGTCGTTCCTTAAATGTTCCAGCGCTGGCACGCAACCTCTCATGCGCTACTTATCACGCCGCGCCAATTTATTACCGCTATGGCCAATTGAATGACACACATTAACAAATTTCGTGAGGAGTCTCCAGAAGAATGCCATTAACTTTTCCGCTGCATAACCCTGCTTCGGGGTCATTATAGCGATTTTTTCGGTATATCCATCCTTTTTCGCACGATATACAGGATTTTGCCAAAGGGTTCGTGTAGACTTTCCTTGGTGTATCCAACGGCGTCAGCCGGGCAGGATAGGTGAAGTAGGCCCACCCGCGAGCGGGTGTTCCTTCTTCACTGTCCCTTATTCGCACCTGGCGGTGCTCAACGGGAATCCTGCTCTGCGAGGCTGGCCGTA"
r2seq = "ATGTGGCACGCCACTACTCACGAGTTCGTTTGCAAAGACATTGATTACCAAGTGATCGTTTCAACTTTTGTCTGTAAGATTAATGGATCTGCTTATGCCGACCAGGTTACCATGGAATACCAGGTTTTAATTACAACTTTGGAGGACATAACCTGTCACATACTCTTGCATGCAGTAGAATACCAAGTCAAAAACCAGTGGATTGGGAGGGCAGATGTCGCTACCGAGGATACCCAGCCCCAGTTCATGTACTGTTTGGCCTCTAGCATAAATACCCACGAGAACGCTGTTTACAGTGAAGCCTTGTCCGCTAACGACATTGTGGAGGACGAAGAAAACATCAACGTCCAACTAGTTGAGGACTAA"
ospace = 0
ogenes = 0
-- First, human peptides
local peptides = parse_tsv("peptides.tsv")
c = 0
genes = {}
for gene, pep in pairs(peptides) do
	-- add m check here
	--
	local t = codon.default_tables["homo_sapiens"]
	local optimized_sequence, err = t:optimize(pep)
	if err ~= nil then print(err) end
	local fixed_sequence, _, err = fix.cds_simple(optimized_sequence, t, {"GGTCTC","CGTCTC","GAAGAC"})
	if err ~= nil then print(err) end
	local standardized_sequence, err = t:standardize_last_codon(fixed_sequence)
	if err ~= nil then print(err) end

    local libf, libr, err = libops:new_primer_set()
    if err ~= nil then print(err) end
    local f,r,err = ops:new_primer_set()
    if err ~= nil then print(err) end

    local stuffer2 = ""
    if #standardized_sequence < 200 then
        stuffer2 = r2seq:sub(1,200-#standardized_sequence)
    end
	local overhang_sequence = "GGAG" .. p165 .. libf .. "GGTCTCTACC" .. standardized_sequence .. "TAA" .. "TAAGTGAGACCT" .. stuffer2 .. transform.reverse_complement(libr) .. transform.reverse_complement(p162) .. "CGCT"
    c = c + #overhang_sequence
    local clone_fragments = {vector}
	local fragments, _, err = fragment.fragment(overhang_sequence, 200, 236, {})
	for j, frag in ipairs(fragments) do
		local prefix_frag = f .. "GAAGACTA" .. frag
		local stuffer = rseq:sub(1,300-(#prefix_frag + 30))
		local full_frag = prefix_frag .. "TAGTCTTCT" .. stuffer .. "T" .. transform.reverse_complement(r)
        ospace = ospace + 1
		--print(j, full_frag, #full_frag)
        sq, _ = seqhash.encode_hash2(seqhash.hash2(full_frag, "DNA", false, false))
        opool = opool .. sq .. "\t" ..  gene .. "__" .. j .. "\t" .. f .. "+" .. r .. "\t" .. full_frag .. "\n"
        table.insert(clone_fragments, {sequence = full_frag, circular = false})
	end
    local cln, _, err = clone.golden_gate(clone_fragments, clone.default_enzymes.BbsI,false)
    if err ~= nil then print(err) end
    clns = clns .. gene .. "\t" .. cln .. "\n"
    ogenes = ogenes + 1
end
print("peptides:", c)

local orphans = parse_tsv("orphan.tsv")
d = 0
for gene, seq in pairs(orphans) do
    local t = codon.default_tables["homo_sapiens"]
    local fixed_sequence, _, err = fix.cds_simple(seq, t, {"GGTCTC","CGTCTC","GAAGAC"})
    if err ~= nil then print(err) end
    local libf, libr, err = libops:new_primer_set()
    if err ~= nil then print(err) end

    local stuffer2 = ""
    if #fixed_sequence < 240 then
        stuffer2 = r2seq:sub(1,240-#fixed_sequence)
    end
    local overhang_sequence = "GGAG" .. p165 .. libf .. "GGTCTCTACC" .. fixed_sequence .. "TAAGTGAGACC" .. stuffer2.. transform.reverse_complement(libr) .. transform.reverse_complement(p162) .. "CGCT"

    d = d + #overhang_sequence

    -- Oligos
    if #overhang_sequence < 3500 then
        local f,r,err = ops:new_primer_set()
        if err ~= nil then print(err) end
        local fragments, _, err = fragment.fragment(overhang_sequence, 200, 236, {})
        local clone_fragments = {vector}
        for j, frag in ipairs(fragments) do
            local prefix_frag = f .. "GAAGACTA" .. frag
            stuffer = rseq:sub(1,300-(#prefix_frag + 30))
            local full_frag = prefix_frag .. "TAGTCTTCT" .. stuffer .. "T" .. transform.reverse_complement(r)
            --print(j, full_frag, #full_frag)
            ospace = ospace + 1
            sq, _ = seqhash.encode_hash2(seqhash.hash2(full_frag, "DNA", false, false))
            opool = opool .. sq .. "\t" .. gene .. "__" .. j .. "\t" .. f .. "+" .. r .. "\t" .. full_frag .. "\n"
            table.insert(clone_fragments, {sequence = full_frag, circular = false})
        end
        local cln, _, err = clone.golden_gate(clone_fragments, clone.default_enzymes.BbsI,false)
        if err ~= nil then print(err) end
        clns = clns .. gene .. "\t" .. cln .. "\n"
        ogenes = ogenes + 1
    end
end
print("orphan:", d)

local orfs = parse_tsv("orfs.tsv")
e = 0
for gene, seq in pairs(orfs) do
    local t = codon.default_tables["homo_sapiens"]
    local fixed_sequence, changes, err = fix.cds_simple(seq, t, {"GGTCTC","CGTCTC","GAAGAC"})
    if err ~= nil then print(err) print(gene) print(seq) end
    local libf, libr, err = libops:new_primer_set()
    if err ~= nil then print(err) end
    local overhang_sequence = "GGAG" .. p165 .. libf .. "GGTCTCTACC" .. fixed_sequence .. "TAAGTGAGACC" .. transform.reverse_complement(libr) .. transform.reverse_complement(p162) .. "CGCT"
    -- Oligos
    if #overhang_sequence < 3500 then
        e = e + #overhang_sequence
        local f,r,err = ops:new_primer_set()
        if err ~= nil then print(err) end
        local fragments, _, err = fragment.fragment(overhang_sequence, 200, 236, {})
        local clone_fragments = {vector}
        for j, frag in ipairs(fragments) do
            local prefix_frag = f .. "GAAGACTA" .. frag
            local stuffer = rseq:sub(1,300-(#prefix_frag + 30))
            local full_frag = prefix_frag .. "TAGTCTTCT" .. stuffer .. "T" .. transform.reverse_complement(r)
            --print(j, full_frag, #full_frag)
            ospace = ospace + 1
            sq, _ = seqhash.encode_hash2(seqhash.hash2(full_frag, "DNA", false, false))
            opool = opool .. sq .. "\t" .. gene .. "__" .. j .. "\t" .. f .. "+" .. r .. "\t" .. full_frag .. "\n"
            table.insert(clone_fragments, {sequence = full_frag, circular = false})
        end
        local cln, _, err = clone.golden_gate(clone_fragments, clone.default_enzymes.BbsI,false)
        if err ~= nil then print(err) end
        clns = clns .. gene .. "\t" .. cln .. "\n"
        ogenes = ogenes + 1
    end
end
print("orfs", e)

libops2 = orthoprimers.new_orthogonal_primer_set(primers)
local parts_data = scan_parts_dir()
f = 0
for filepath, data in pairs(parts_data) do
    --for key, value in pairs(data) do
    --    print("  " .. key .. ": " .. value)
    --end
	
	-- Add BbsI and BsaI check here
	local libf, libr, err = libops2:new_primer_set()
    terminator_prefix = ""
    if data["terminator_prefix"] then
        terminator_prefix = data["terminator_prefix"]
    end
    local s_len = data["prefix"] .. data["sequence"] .. data["suffix"]
    local stuffer2 = ""
    if #s_len < 240 then
        stuffer2 = r2seq:sub(1,240-#s_len)
    end
	local overhang_sequence = "GGAGT" .. phiBT1_ga .. terminator_prefix .. p165 .. libf .. "GGTCTCT" .. data["prefix"] .. data["sequence"] .. data["suffix"] .. "TGAGACCT" ..stuffer2 .. "T" .. transform.reverse_complement(libr) .. transform.reverse_complement(p162) .. phiBT1_tc .. "TCGCT"
    f = f + #overhang_sequence

    -- Full fragment
        local fragments, _, err = fragment.fragment(overhang_sequence, 4000,4900, {})
        local clone_fragments = {vector}
        for j, frag in ipairs(fragments) do
            local full_frag = p158 .. "GAAGACTA" .. frag .. "TAGTCTTCT" .. transform.reverse_complement(p159)
            --print(j, full_frag, #full_frag)
            sq, _ = seqhash.encode_hash2(seqhash.hash2(full_frag, "DNA", false, true))
            twist_fragments = twist_fragments .. sq .. "\t" .. data["name"] .. "__" .. j .. "\t" .. full_frag .. "\n"
            table.insert(clone_fragments, {sequence = full_frag, circular = false})
        end
        local cln, _, err = clone.golden_gate(clone_fragments, clone.default_enzymes.BbsI,false)
        if err ~= nil then print(err) print(data["name"]) end
        clns = clns .. "fragment__" .. data["name"] .. "\t" .. cln .. "\n"

    -- Oligos
    if #overhang_sequence < 3500 then
        local f,r,err = ops:new_primer_set()
        if err ~= nil then print(err) end
        local fragments, _, err = fragment.fragment(overhang_sequence, 200, 236, {})
        local clone_fragments = {vector}
        for j, frag in ipairs(fragments) do
            local prefix_frag = f .. "GAAGACTA" .. frag
            local stuffer = rseq:sub(1,300-(#prefix_frag + 30))
            local full_frag = prefix_frag .. "TAGTCTTCT" .. stuffer .. "T" .. transform.reverse_complement(r)
            --print(j, full_frag, #full_frag)
            ospace = ospace + 1
            sq, _ = seqhash.encode_hash2(seqhash.hash2(full_frag, "DNA", false, false))
            opool = opool .. sq .. "\t" .. data["name"] .. "__" .. j .. "\t" .. f .. "+" .. r .. "\t" .. full_frag .. "\n"
            table.insert(clone_fragments, {sequence = full_frag, circular = false})
        end
        local cln, _, err = clone.golden_gate(clone_fragments, clone.default_enzymes.BbsI,false)
        if err ~= nil then print(err) print(data["name"]) end
        clns = clns .. data["name"] .. "\t" .. cln .. "\n"
        genes = ogenes + 1
    end
    --print(seq)
end

--
--
--
--
--

-- Define nattokinase-specific data
local prsa_promoters = {
    Pveg = promoters.Pveg,
    P43 = promoters.P43,
    PtrnQ = promoters.PtrnQ
}

-- Function to build a part with prefix/suffix and make it 300bp with stuffer
local function build_natto_part(sequence, prefix, suffix, part_name)
    local part_sequence = prefix .. sequence .. suffix
    local wrapped_sequence = "GGTCTCT" .. part_sequence .. "TGAGACCT"
    
    -- If sequence fits in 300bp, build single part
    local f, r, err = ops:new_primer_set()
    if err ~= nil then print(err) end
    
    local test_length = #f + #wrapped_sequence + #transform.reverse_complement(r)
    if test_length <= 300 then
        local stuffer_needed = 300 - test_length
        local stuffer = ""
        if stuffer_needed > 0 then
            stuffer = rseq:sub(1, stuffer_needed)
        end
        
        local full_sequence = f .. wrapped_sequence .. stuffer .. transform.reverse_complement(r)
        return {{sequence = full_sequence, name = part_name, forward = f, reverse = r}}
    else
        -- Split into fragments
        local fragments, _, err = fragment.fragment(part_sequence, 200, 236, {"AACT","TACA","GCTG"})
        if err ~= nil then print(err) end
        
        local result_parts = {}
        for j, frag in ipairs(fragments) do
            local frag_f, frag_r, err = ops:new_primer_set()
            if err ~= nil then print(err) end
            
            local prefix_frag = frag_f .. "GGTCTCT" .. frag
            local stuffer = rseq:sub(1, 300 - (#prefix_frag + 30))
            local full_frag = prefix_frag .. "TGAGACCT" .. stuffer .. "T" .. transform.reverse_complement(frag_r)
            
            table.insert(result_parts, {
                sequence = full_frag, 
                name = part_name .. "__" .. j, 
                forward = frag_f, 
                reverse = frag_r
            })
        end
        return result_parts
    end
end

-- Build all nattokinase parts
local natto_prsa_parts = {}
for name, seq in pairs(prsa_promoters) do
    local parts = build_natto_part(seq, "TGTA", "TAGG", "natto_prsa_" .. name)
    natto_prsa_parts[name] = {}
    for _, part in ipairs(parts) do
        table.insert(natto_prsa_parts[name], {
            sequence = part.sequence, 
            forward = part.forward, 
            reverse = part.reverse,
            circular = false
        })
        ospace = ospace + 1
        local sq, _ = seqhash.encode_hash2(seqhash.hash2(part.sequence, "DNA", false, false))
        opool = opool .. sq .. "\t" .. part.name .. "\t" .. part.forward .. "+" .. part.reverse .. "\t" .. part.sequence .. "\n"
    end
end

local natto_promoter_parts = {}
for name, seq in pairs(promoters) do
    local parts = build_natto_part(seq, "TACA", "AACT", "natto_promoter_" .. name)
    natto_promoter_parts[name] = {}
    for _, part in ipairs(parts) do
        table.insert(natto_promoter_parts[name], {
            sequence = part.sequence, 
            forward = part.forward, 
            reverse = part.reverse,
            circular = false
        })
        ospace = ospace + 1
        local sq, _ = seqhash.encode_hash2(seqhash.hash2(part.sequence, "DNA", false, false))
        opool = opool .. sq .. "\t" .. part.name .. "\t" .. part.forward .. "+" .. part.reverse .. "\t" .. part.sequence .. "\n"
    end
end

local natto_signal_parts = {}
for name, seq in pairs(signal_peptides) do
    local parts = build_natto_part(seq, "AACT", "GCTG", "natto_signal_" .. name)
    natto_signal_parts[name] = {}
    for _, part in ipairs(parts) do
        table.insert(natto_signal_parts[name], {
            sequence = part.sequence, 
            forward = part.forward, 
            reverse = part.reverse,
            circular = false
        })
        ospace = ospace + 1
        local sq, _ = seqhash.encode_hash2(seqhash.hash2(part.sequence, "DNA", false, false))
        opool = opool .. sq .. "\t" .. part.name .. "\t" .. part.forward .. "+" .. part.reverse .. "\t" .. part.sequence .. "\n"
    end
end

-- Generate combinations and simulate cloning with BsaI
for prsa_name, prsa_parts in pairs(natto_prsa_parts) do
    for prom_name, prom_parts in pairs(natto_promoter_parts) do
        -- Skip if same promoter name (avoid Pveg-Pveg, etc.)
        if prsa_name ~= prom_name then
            for sig_name, sig_parts in pairs(natto_signal_parts) do
                local construct_name = "nattok_" .. prsa_name .. "_" .. prom_name .. "_" .. sig_name
                
                local clone_fragments = {natto_vector}
                
                -- Add all fragments for each part type
                for _, part in ipairs(prsa_parts) do
                    table.insert(clone_fragments, part)
                end
                for _, part in ipairs(prom_parts) do
                    table.insert(clone_fragments, part)
                end
                for _, part in ipairs(sig_parts) do
                    table.insert(clone_fragments, part)
                end
                
                local cln, _, err = clone.golden_gate(clone_fragments, clone.default_enzymes.BsaI, false)
                if err ~= nil then 
                    print("Error for " .. construct_name .. ": " .. err) 
                else
                    clns = clns .. construct_name .. "\t" .. cln .. "\n"
                    ogenes = ogenes + 1
                end
            end
        end
    end
end

print("kg toolkits:", f)
print("Total: ", c+d+e+f)
print("ospace: ", ospace)
print("ogenes: ", ogenes)
io.open("opool.tsv", "w"):write(opool):close()
io.open("fragments.tsv", "w"):write(twist_fragments):close()
io.open("clns.tsv", "w"):write(clns):close()
