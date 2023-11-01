BEGIN TRANSACTION;
DROP TABLE IF EXISTS "audit";
CREATE TABLE IF NOT EXISTS "audit" (
	"pk"	INTEGER,
	"status"	INTEGER,
	PRIMARY KEY("pk" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "batch";
CREATE TABLE IF NOT EXISTS "batch" (
	"pk"	INTEGER,
	"data_dir"	TEXT NOT NULL UNIQUE,
	"batch_alias"	TEXT NOT NULL UNIQUE,
	"dsg_fastq_dirpath"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("pk" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "corrected_sample";
CREATE TABLE IF NOT EXISTS "corrected_sample" (
	"pk"	INTEGER,
	"library_id"	TEXT NOT NULL UNIQUE,
	"whatdatall_id"	TEXT NOT NULL,
	"reason"	TEXT NOT NULL,
	PRIMARY KEY("pk" AUTOINCREMENT),
	FOREIGN KEY("library_id") REFERENCES "sample"("pk")
);
DROP TABLE IF EXISTS "fastq";
CREATE TABLE IF NOT EXISTS "fastq" (
	"pk"	INTEGER,
	"library_id"	INTEGER,
	"fastq_1"	TEXT NOT NULL,
	"fastq_2"	TEXT NOT NULL,
	"dsg_location"	TEXT,
	"strandedness"	TEXT NOT NULL,
	"index_sequence"	TEXT NOT NULL,
	"flow_cell_id"	TEXT NOT NULL,
	"lane"	TEXT NOT NULL CHECK("lane" IN ('L001', 'L002', 'L003', 'L004')),
	"type"	TEXT NOT NULL,
	"notes"	TEXT DEFAULT 'none',
	PRIMARY KEY("pk" AUTOINCREMENT),
	FOREIGN KEY("library_id") REFERENCES "sample"
);
DROP TABLE IF EXISTS "id_correction";
CREATE TABLE IF NOT EXISTS "id_correction" (
	"reason"	TEXT,
	"source"	TEXT,
	PRIMARY KEY("reason")
);
DROP TABLE IF EXISTS "multiqc_general";
CREATE TABLE IF NOT EXISTS "multiqc_general" (
	"pk"	INTEGER,
	"library_id"	INTEGER,
	"general.dupradar_intercept"	REAL,
	"general.percent_rrna"	REAL,
	"general.library"	TEXT,
	"general.unpaired_reads_examined"	INTEGER,
	"general.read_pairs_examined"	INTEGER,
	"general.secondary_or_supplementary_rds"	INTEGER,
	"general.unmapped_reads"	INTEGER,
	"general.unpaired_read_duplicates"	INTEGER,
	"general.read_pair_duplicates"	INTEGER,
	"general.read_pair_optical_duplicates"	INTEGER,
	"general.percent_duplication"	INTEGER,
	"general.estimated_library_size"	INTEGER,
	"general.5_3_bias"	REAL,
	"general.reads_aligned"	INTEGER,
	"general.unalignable"	INTEGER,
	"general.alignable"	INTEGER,
	"general.filtered"	INTEGER,
	"general.total"	INTEGER,
	"general.alignable_percent"	REAL,
	"general.unique"	INTEGER,
	"general.multi"	INTEGER,
	"general.uncertain"	INTEGER,
	"general.total_records"	INTEGER,
	"general.qc_failed"	INTEGER,
	"general.optical_pcr_duplicate"	INTEGER,
	"general.non_primary_hits"	INTEGER,
	"general.mapq_lt_mapq_cut_non_unique"	INTEGER,
	"general.mapq_gte_mapq_cut_unique"	INTEGER,
	"general.read_1"	INTEGER,
	"general.read_2"	INTEGER,
	"general.reads_map_to_sense"	INTEGER,
	"general.reads_map_to_antisense"	INTEGER,
	"general.non_splice_reads"	INTEGER,
	"general.splice_reads"	INTEGER,
	"general.reads_mapped_in_proper_pairs"	INTEGER,
	"general.proper_paired_reads_map_to_different_chrom"	INTEGER,
	"general.unique_percent"	REAL,
	"general.proper_pairs_percent"	REAL,
	"general.raw_total_sequences"	INTEGER,
	"general.filtered_sequences"	INTEGER,
	"general.sequences"	INTEGER,
	"general.is_sorted"	INTEGER,
	"general.1st_fragments"	INTEGER,
	"general.last_fragments"	INTEGER,
	"general.reads_mapped"	INTEGER,
	"general.reads_mapped_and_paired"	INTEGER,
	"general.reads_unmapped"	INTEGER,
	"general.reads_properly_paired"	INTEGER,
	"general.reads_paired"	INTEGER,
	"general.reads_duplicated"	INTEGER,
	"general.reads_mq0"	INTEGER,
	"general.reads_qc_failed"	INTEGER,
	"general.non_primary_alignments"	INTEGER,
	"general.supplementary_alignments"	INTEGER,
	"general.total_length"	INTEGER,
	"general.total_first_fragment_length"	INTEGER,
	"general.total_last_fragment_length"	INTEGER,
	"general.bases_mapped"	INTEGER,
	"general.bases_mapped_cigar"	INTEGER,
	"general.bases_trimmed"	INTEGER,
	"general.bases_duplicated"	INTEGER,
	"general.mismatches"	INTEGER,
	"general.error_rate"	REAL,
	"general.average_length"	INTEGER,
	"general.average_first_fragment_length"	INTEGER,
	"general.average_last_fragment_length"	INTEGER,
	"general.maximum_length"	INTEGER,
	"general.maximum_first_fragment_length"	INTEGER,
	"general.maximum_last_fragment_length"	INTEGER,
	"general.average_quality"	REAL,
	"general.insert_size_average"	REAL,
	"general.insert_size_standard_deviation"	REAL,
	"general.inward_oriented_pairs"	INTEGER,
	"general.outward_oriented_pairs"	INTEGER,
	"general.pairs_with_other_orientation"	INTEGER,
	"general.pairs_on_different_chromosomes"	INTEGER,
	"general.percentage_of_properly_paired_reads_%"	REAL,
	"general.reads_mapped_percent"	REAL,
	"general.reads_mapped_and_paired_percent"	REAL,
	"general.reads_unmapped_percent"	REAL,
	"general.reads_properly_paired_percent"	REAL,
	"general.reads_paired_percent"	REAL,
	"general.reads_duplicated_percent"	REAL,
	"general.reads_mq0_percent"	REAL,
	"general.reads_qc_failed_percent"	REAL,
	"general.total_passed"	INTEGER,
	"general.total_failed"	INTEGER,
	"general.secondary_passed"	INTEGER,
	"general.secondary_failed"	INTEGER,
	"general.supplementary_passed"	INTEGER,
	"general.supplementary_failed"	INTEGER,
	"general.duplicates_passed"	INTEGER,
	"general.duplicates_failed"	INTEGER,
	"general.mapped_passed"	INTEGER,
	"general.mapped_failed"	INTEGER,
	"general.mapped_passed_pct"	REAL,
	"general.mapped_failed_pct"	REAL,
	"general.paired_in_sequencing_passed"	INTEGER,
	"general.paired_in_sequencing_failed"	INTEGER,
	"general.read1_passed"	INTEGER,
	"general.read1_failed"	INTEGER,
	"general.read2_passed"	INTEGER,
	"general.read2_failed"	INTEGER,
	"general.properly_paired_passed"	INTEGER,
	"general.properly_paired_failed"	INTEGER,
	"general.properly_paired_passed_pct"	REAL,
	"general.properly_paired_failed_pct"	REAL,
	"general.with_itself_and_mate_mapped_passed"	INTEGER,
	"general.with_itself_and_mate_mapped_failed"	INTEGER,
	"general.singletons_passed"	INTEGER,
	"general.singletons_failed"	INTEGER,
	"general.singletons_passed_pct"	REAL,
	"general.singletons_failed_pct"	REAL,
	"general.with_mate_mapped_to_a_different_chr_passed"	INTEGER,
	"general.with_mate_mapped_to_a_different_chr_failed"	INTEGER,
	"general.with_mate_mapped_to_a_different_chr_mapq__5_passed"	INTEGER,
	"general.with_mate_mapped_to_a_different_chr_mapq__5_failed"	INTEGER,
	"general.flagstat_total"	INTEGER,
	"general.percent_gc"	REAL,
	"general.avg_sequence_length"	REAL,
	"general.total_sequences"	REAL,
	"general.percent_duplicates"	REAL,
	"general.percent_fails"	REAL,
	"general.r_processed"	INTEGER,
	"general.r_with_adapters"	INTEGER,
	"general.r_written"	INTEGER,
	"general.bp_processed"	REAL,
	"general.quality_trimmed"	INTEGER,
	"general.bp_written"	REAL,
	"general.percent_trimmed"	REAL,
	FOREIGN KEY("library_id") REFERENCES "sample"("pk"),
	PRIMARY KEY("pk" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "qualimap_genomic_origin";
CREATE TABLE IF NOT EXISTS "qualimap_genomic_origin" (
	"pk"	INTEGER,
	"library_id"	TEXT NOT NULL,
	"exonic"	INTEGER NOT NULL,
	"intronic"	INTEGER NOT NULL,
	"intergenic"	INTEGER NOT NULL,
	PRIMARY KEY("pk" AUTOINCREMENT),
	FOREIGN KEY("library_id") REFERENCES "sample"("pk")
);
DROP TABLE IF EXISTS "remove_ids";
CREATE TABLE IF NOT EXISTS "remove_ids" (
	"pk"	INTEGER,
	"id"	INTEGER NOT NULL UNIQUE,
	"source"	TEXT NOT NULL,
	"reason"	TEXT NOT NULL,
	PRIMARY KEY("pk" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "rsem_assignment_plot";
CREATE TABLE IF NOT EXISTS "rsem_assignment_plot" (
	"pk"	INTEGER,
	"library_id"	TEXT NOT NULL,
	"aligned_uniquely_to_a_gene"	INTEGER NOT NULL,
	"aligned_to_multiple_genes"	INTEGER NOT NULL,
	"filtered_due_to_too_many_alignments"	INTEGER NOT NULL,
	"unalignable_reads"	INTEGER NOT NULL,
	PRIMARY KEY("pk" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "rsem_quant";
CREATE TABLE IF NOT EXISTS "rsem_quant" (
	"pk"	INTEGER,
	"library_id"	INTEGER,
	"rsem_isoform_quant"	TEXT NOT NULL,
	PRIMARY KEY("pk" AUTOINCREMENT),
	FOREIGN KEY("pk") REFERENCES "fastq"("pk")
);
DROP TABLE IF EXISTS "sample";
CREATE TABLE IF NOT EXISTS "sample" (
	"pk"	INTEGER,
	"fastq_id"	TEXT NOT NULL,
	"visit"	TEXT NOT NULL CHECK("visit" IN ('0', '1', '2', '3')),
	"batch_id"	INTEGER NOT NULL,
	"mislabelled"	INTEGER NOT NULL CHECK("mislabelled" IN (0, 1)),
	"suspicious_sex"	INTEGER NOT NULL CHECK("suspicious_sex" IN (0, 1)),
	PRIMARY KEY("pk" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "samtools_idxstats_xy_plot";
CREATE TABLE IF NOT EXISTS "samtools_idxstats_xy_plot" (
	"pk"	INTEGER,
	"library_id"	TEXT NOT NULL,
	"chromosome_x"	INTEGER NOT NULL,
	"chromosome_y"	INTEGER NOT NULL,
	PRIMARY KEY("pk" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "transfer_library_ids";
CREATE TABLE IF NOT EXISTS "transfer_library_ids" (
	"pk"	INTEGER,
	"fastq_id"	TEXT UNIQUE,
	"whatdatall_id"	TEXT UNIQUE,
	"visit"	TEXT CHECK("visit" IN (1, 2, 3)),
	PRIMARY KEY("pk" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "wgs_compare";
CREATE TABLE IF NOT EXISTS "wgs_compare" (
	"pk"	INTEGER,
	"library_id"	INTEGER,
	"dna_subject"	INTEGER NOT NULL,
	"chr"	TEXT NOT NULL,
	"total_variants"	INTEGER NOT NULL,
	"matching_variants"	INTEGER NOT NULL,
	"homo_expr_cand"	INTEGER NOT NULL,
	"match_ratio"	REAL NOT NULL,
	PRIMARY KEY("pk" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "whatdatall";
CREATE TABLE IF NOT EXISTS "whatdatall" (
	"pk"	INTEGER,
	"id"	INTEGER NOT NULL UNIQUE,
	"subject"	INTEGER NOT NULL UNIQUE,
	"sex"	INTEGER NOT NULL CHECK("sex" IN (1, 2)),
	"source"	TEXT NOT NULL,
	"notes"	TEXT NOT NULL DEFAULT 'none',
	PRIMARY KEY("pk" AUTOINCREMENT)
);
DROP VIEW IF EXISTS "genomic_origin_view";
CREATE VIEW genomic_origin_view AS
SELECT 
    pk,
    library_id,
    exonic,
    intronic,
    intergenic,
    CAST(exonic AS REAL) / (CAST(exonic AS REAL) + CAST(intronic AS REAL) + CAST(intergenic AS REAL)) AS percent_exonic,
	CAST(intronic AS REAL) / (CAST(exonic AS REAL) + CAST(intronic AS REAL) + CAST(intergenic AS REAL)) AS percent_intronic,
	CAST(intergenic AS REAL) / (CAST(exonic AS REAL) + CAST(intronic AS REAL) + CAST(intergenic AS REAL)) AS percent_intergenic
FROM 
    qualimap_genomic_origin;
DROP VIEW IF EXISTS "llfs_rnaseq_metadata";
CREATE VIEW "llfs_rnaseq_metadata" AS 
SELECT subquery.library_id, 
       subquery.batch_id, 
	   subquery.batch_alias, 
	   subquery.fastq_id, 
	   subquery.visit, 
	   COALESCE(subquery.reason, "NA") AS relabel_reason,
	   COALESCE(subquery.mislabelled, 0) AS mislabelled,
	   COALESCE(subquery.suspicious_sex,0) AS suspicious_sex,
	   COALESCE(remove_ids.reason,"yes") AS legal,
	   whatdatall.id AS whatdatall_id, 
	   whatdatall.subject,
	   whatdatall.sex,
	   xy_ratio.chromosome_x,
	   xy_ratio.chromosome_y,
	   xy_ratio.y_x_ratio,
	   genomic_origin_view.exonic,
	   genomic_origin_view.intronic,
	   genomic_origin_view.intergenic,
	   genomic_origin_view.percent_exonic,
	   genomic_origin_view.percent_intronic,
	   genomic_origin_view.percent_intergenic
FROM 
    (SELECT sample.pk as library_id,
	        sample.fastq_id,
			sample.visit,
			sample.mislabelled,
			sample.suspicious_sex,
       COALESCE(corrected_sample.whatdatall_id, sample.fastq_id) AS corrected_id,
	   corrected_sample.reason,
	   batch.pk AS batch_id,
	   batch.batch_alias
	FROM sample
	LEFT JOIN corrected_sample ON sample.pk = corrected_sample.library_id
	LEFT JOIN batch ON sample.batch_id = batch.pk
    ) AS subquery
LEFT JOIN whatdatall ON subquery.corrected_id = whatdatall.id
LEFT JOIN xy_ratio ON subquery.library_id = xy_ratio.library_id
LEFT JOIN genomic_origin_view ON subquery.library_id = genomic_origin_view.library_id
LEFT JOIN remove_ids ON whatdatall.id = remove_ids.id;
DROP VIEW IF EXISTS "xy_ratio";
CREATE VIEW xy_ratio AS
SELECT 
    pk,
    library_id,
    chromosome_x,
    chromosome_y,
    CAST(chromosome_y AS REAL) / CAST(chromosome_x AS REAL) AS y_x_ratio
FROM 
    samtools_idxstats_xy_plot;
DROP INDEX IF EXISTS "batch_index";
CREATE INDEX IF NOT EXISTS "batch_index" ON "batch" (
	"pk",
	"data_dir",
	"batch_alias"
);
DROP INDEX IF EXISTS "corrected_sample_index";
CREATE INDEX IF NOT EXISTS "corrected_sample_index" ON "corrected_sample" (
	"pk",
	"library_id",
	"whatdatall_id"
);
DROP INDEX IF EXISTS "fastq_index";
CREATE INDEX IF NOT EXISTS "fastq_index" ON "fastq" (
	"pk",
	"library_id"
);
DROP INDEX IF EXISTS "multiqc_general_index";
CREATE INDEX IF NOT EXISTS "multiqc_general_index" ON "multiqc_general" (
	"pk",
	"library_id"
);
DROP INDEX IF EXISTS "qualimap_genomic_origin_index";
CREATE INDEX IF NOT EXISTS "qualimap_genomic_origin_index" ON "qualimap_genomic_origin" (
	"pk",
	"library_id"
);
DROP INDEX IF EXISTS "remove_ids_index";
CREATE INDEX IF NOT EXISTS "remove_ids_index" ON "remove_ids" (
	"pk",
	"id"
);
DROP INDEX IF EXISTS "rsem_assignment_plot_index";
CREATE INDEX IF NOT EXISTS "rsem_assignment_plot_index" ON "rsem_assignment_plot" (
	"pk",
	"library_id"
);
DROP INDEX IF EXISTS "sample_index";
CREATE INDEX IF NOT EXISTS "sample_index" ON "sample" (
	"pk",
	"fastq_id"
);
DROP INDEX IF EXISTS "samtools_idxstats_xy_plot_index";
CREATE INDEX IF NOT EXISTS "samtools_idxstats_xy_plot_index" ON "samtools_idxstats_xy_plot" (
	"pk",
	"library_id"
);
DROP INDEX IF EXISTS "transfer_library_ids_index";
CREATE INDEX IF NOT EXISTS "transfer_library_ids_index" ON "transfer_library_ids" (
	"pk",
	"fastq_id",
	"whatdatall_id"
);
DROP INDEX IF EXISTS "wgs_compare_index";
CREATE INDEX IF NOT EXISTS "wgs_compare_index" ON "wgs_compare" (
	"pk",
	"library_id",
	"dna_subject"
);
DROP INDEX IF EXISTS "whatdatall_index";
CREATE INDEX IF NOT EXISTS "whatdatall_index" ON "whatdatall" (
	"id",
	"pk",
	"subject"
);
COMMIT;
