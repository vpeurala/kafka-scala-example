lazy val root = (project in file(".")).
  settings(
    inThisBuild(List(
      organization := "fi.villepeurala",
      scalaVersion := "2.12.12"
    )),
    name := "kafka-scala-example"
  )

libraryDependencies += "org.scalatest" %% "scalatest" % "3.2.2" % Test
