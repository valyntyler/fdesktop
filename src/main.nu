#!/usr/bin/env nu

def main [
  app: string
] {
  symdig $app
  | path dirname
  | path join ../share/applications
  | path expand
  | ls $in
  | get name
  | path basename
}
