test_that("duckmap_summary(plot = FALSE) reports palette metadata", {
  info <- duckmap_summary(plot = FALSE)
  expect_s3_class(info, "data.frame")
  expect_true(all(c("palette", "type", "default", "default_n", "styles") %in% names(info)))
  expect_true("full_plumage" %in% info$palette)
  expect_true("wetland_dabbler" %in% info$palette)
  expect_true("wing_flash" %in% info$palette)
  expect_true("iridescent" %in% info$palette)
  expect_false("wetland_dusk" %in% info$palette)
  expect_false("bronze_wing" %in% info$palette)
  expect_true("umber_teal" %in% info$palette)
  expect_true("copper_blue" %in% info$palette)
  expect_false("orange_blue" %in% info$palette)
  expect_equal(sum(info$type == "divergent"), 6L)
  expect_true("archetype" %in% info$palette)
  expect_false("categorical" %in% info$palette)
  expect_true(any(info$type == "sequential"))
  expect_true(any(info$type == "divergent"))
  expect_true(any(info$type == "categorical"))
  expect_false(exists("duckmap_info", mode = "function"))
})

test_that("duckmap generates palettes by name without type", {
  expect_equal(length(duckmap("viriduck", n = 9)), 9)
  expect_equal(length(duckmap("wetland_dabbler", n = 9)), 9)
  expect_equal(length(duckmap("wing_flash", n = 9)), 9)
  expect_equal(length(duckmap("iridescent", n = 9)), 9)
  expect_error(duckmap("wetland_dusk", n = 9))
  expect_error(duckmap("bronze_wing", n = 9))
  expect_equal(length(duckmap("umber_teal", n = 11)), 11)
  expect_equal(length(duckmap("copper_blue")), 257)
  expect_error(duckmap("orange_blue"))
  for (p in c("umber_teal", "orange_teal", "orange_violet", "chestnut_violet", "copper_blue", "rose_blue")) {
    expect_equal(length(duckmap(p, n = 11)), 11)
  }
  expect_equal(length(duckmap(type = "seq")), 256)
  expect_equal(length(duckmap(type = "sequential")), 256)
  expect_equal(length(duckmap(type = "div")), 257)
  expect_equal(length(duckmap(type = "divergent")), 257)
})

test_that("categorical palette supports n and colors", {
  expect_equal(length(duckmap(type = "cat")), 7)
  expect_equal(length(duckmap(type = "categorical", n = 3)), 3)
  sub <- duckmap(type = "cat", colors = c("mallard_teal", "soft_gold"))
  expect_equal(length(sub), 2)
  expect_equal(unname(sub), unname(duckmap(type = "cat"))[c(1, 6)])
  expect_equal(names(sub), c("mallard_teal", "soft_gold"))
  expect_equal(length(duckmap("archetype")), 7)
  expect_equal(unname(duckmap("archetype")["eggshell"]), "#F5F2DF")
  expect_equal(length(duckmap(type = "cat", colors = c("mallard_teal", "soft_gold"), n = 5)), 5)
  expect_error(duckmap("mallard_teal", type = "cat"))
})

test_that("vivid sequential style is available and constrained", {
  standard <- duckmap("full_plumage", n = 9, style = "standard")
  vivid <- duckmap("full_plumage", n = 9, style = "vivid")
  expect_equal(length(vivid), 9)
  expect_false(identical(standard, vivid))
  expect_error(duckmap("umber_teal", n = 9, style = "vivid"))
})

test_that("even divergent n warns", {
  expect_warning(duckmap("copper_blue", n = 10), "even")
  expect_silent(duckmap("copper_blue", n = 11))
})


test_that("scale helpers use singular names", {
  expect_true(is.function(scale_fill_duckmap))
  expect_true(is.function(scale_color_duckmap))
  expect_true(is.function(scale_colour_duckmap))
  expect_false(exists("scale_fill_duckmaps", mode = "function"))
  expect_false(exists("scale_color_duckmaps", mode = "function"))
})

test_that("duckmap_custom builds and generates a usable palette", {
  anchors <- data.frame(
    t = c(0, 0.333, 0.667, 1),
    L = c(20, 51, 70, 95),
    a = c(38, 21, 24, -1),
    b = c(-51, -25, 19, 3)
  )
  map <- duckmap_custom(anchors = anchors, name = "custom")
  expect_s3_class(map, "duckmap_palette")
  expect_equal(map$name, "custom")

  cols <- duckmap(map, n = 11)
  expect_equal(length(cols), 11)
  expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", cols)))
  expect_equal(length(duckmap(map, n = 5)), 5)
  expect_equal(length(duckmap(map)), 256)
  expect_equal(duckmap(map, n = 11, reverse = TRUE), rev(duckmap(map, n = 11)))

  # default name and t-less anchors
  map2 <- duckmap_custom(data.frame(L = c(20, 95), a = c(38, -1), b = c(-51, 3)))
  expect_equal(map2$name, "custom")
  expect_equal(length(duckmap(map2, n = 7)), 7)
})

test_that("duckmap_custom integrates with ggplot2 scales", {
  map <- duckmap_custom(data.frame(L = c(20, 60, 95), a = c(30, 10, -1), b = c(-40, 0, 3)))
  expect_s3_class(scale_fill_duckmap(map), "ScaleContinuous")
  expect_s3_class(scale_color_duckmap(map), "ScaleContinuous")
  expect_s3_class(scale_fill_duckmap(map, discrete = TRUE), "ScaleDiscrete")
})

test_that("duckmap_custom validates anchors", {
  expect_error(duckmap_custom(list(L = 1, a = 1, b = 1)))
  expect_error(duckmap_custom(data.frame(L = 20, a = 30, b = -40)))
  expect_error(duckmap_custom(data.frame(L = c(20, 95), a = c(30, -1))))
  expect_error(duckmap_custom(data.frame(L = c(20, 95), a = c(30, -1), b = c(-40, 3)), name = c("a", "b")))
})
