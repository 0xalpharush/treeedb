use std::process::Command;

use assert_cmd::prelude::*;
use predicates::prelude::*;
use tempfile::NamedTempFile;

#[test]
fn gen() -> Result<(), Box<dyn std::error::Error>> {
    let mut cmd = Command::cargo_bin("treeedbgen-souffle-csharp")?;
    let tmp = NamedTempFile::new()?;
    cmd.arg("-o").arg(tmp.path());
    cmd.arg("--prefix=c_sharp").arg("--printsize");
    cmd.assert()
        .success()
        .stdout(predicate::str::is_empty())
        .stderr(predicate::str::is_empty());

    let mut cmd = Command::cargo_bin("treeedb-csharp")?;
    cmd.arg("tests/csharp/hello-world.cs");
    cmd.assert()
        .success()
        .stdout(predicate::str::is_empty())
        .stderr(predicate::str::is_empty());

    let mut souffle = Command::new("souffle");
    souffle.arg(tmp.path());
    souffle
        .assert()
        .success()
        .stdout(predicate::str::contains("c_sharp_node\t28"))
        .stderr(predicate::str::is_empty());
    Ok(())
}
