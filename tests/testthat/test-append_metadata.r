library(dplyr)

test_that("error arises if gps and/or references are of the wrong class", {
  expect_error(append_metadata(gps = 1,
                               reference_data = lbbg_reference),
              "`gps` must be of class data.table, data.frame or matrix.")
  expect_error(append_metadata(gps = lbbg_gps,
                               reference_data = "bad bad bad"),
               "`reference_data` must be of class data.table, data.frame or matrix.")
})

test_that("gps doesn't contain one or more of the mandatory columns", {

  gps_without_canonical_name <- lbbg_gps %>%
    select(-"individual-taxon-canonical-name")

  expect_error(append_metadata(gps = gps_without_canonical_name,
                               reference_data = lbbg_reference),
               "Can't find column(s) `individual-taxon-canonical-name` in `gps`.",
               fixed = TRUE)

  gps_without_canonical_name_identifier <- lbbg_gps %>%
    select(-c("individual-taxon-canonical-name", "tag-local-identifier"))

  expect_error(append_metadata(gps = gps_without_canonical_name_identifier,
                               reference_data = lbbg_reference),
               paste0(
                 "Can't find column(s) `individual-taxon-canonical-name`,",
                 "`tag-local-identifier` in `gps`."),
               fixed = TRUE)
})

test_that("reference_data doesn't contain mandatory columns", {

  ref_cols_too_few = c("animal-taxon")

  expect_error(append_metadata(gps = lbbg_gps,
                               reference_data = lbbg_reference,
                               reference_cols = ref_cols_too_few),
               paste0("reference_data column(s) `tag-id`,",
                      "`animal-id` must be selected."),
               fixed = TRUE)
})

test_that("reference_data doesn't contain all columns we want to add to gps", {

  reference_without_comments <-
    lbbg_reference %>%
    select(-"animal-comments")
  ref_cols_test <- c("animal-taxon",
                     "tag-id",
                     "animal-id",
                     "animal-comments")

  expect_error(append_metadata(gps = lbbg_gps,
                               reference_data = reference_without_comments,
                               reference_cols = ref_cols_test),
               "Can't find column(s) `animal-comments` in `reference_data`.",
               fixed = TRUE)
})

test_that("output is a data.table object",
          expect_true("data.table" %in%
                        class(append_metadata(lbbg_gps,
                                              lbbg_reference))))

test_that("output has all columns from gps and reference data in right order", {
  # Arrange
  cols_from_gps_minimal <- c("event-id",
                     "location-long",
                     "location-lat",
                     "gps:dop",
                     "gps:satellite-count")
  cols_from_gps_for_join <- c("individual-taxon-canonical-name",
                              "tag-local-identifier",
                              "individual-local-identifier")
  gps_minimal <-
    lbbg_gps %>%
    select(one_of(c(cols_from_gps_minimal, cols_from_gps_for_join)))

  cols_from_ref_minimal <- c("animal-taxon",
                             "tag-id",
                             "animal-id",
                             "deploy-on-date",
                             "deploy-off-date",
                             "animal-nickname",
                             "animal-ring-id")
  ref_minimal <-
    lbbg_reference %>%
    select(cols_from_ref_minimal)

  output_col_names <- c(cols_from_gps_minimal, cols_from_ref_minimal)

  # Act
  output <- append_metadata(gps_minimal,
                         ref_minimal,
                         reference_cols = cols_from_ref_minimal)

  # Assert
  expect_true(all(output_col_names == colnames(output)))
})
