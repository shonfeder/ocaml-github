open Printf
open Github_t

let token = Config.access_token

let t =
  let open Github in
  let open Monad in
  run (
    Repo.info ~token ~user:"ocaml" ~repo:"opam" ()
    >>~ fun info ->
    let descr = match info.repository_description with
      | Some descr -> descr
      | None -> ""
    in
    eprintf "repo %s\n" descr;
    begin match info.repository_permissions with
      | Some permissions ->
        eprintf "permissions admin(%B) push(%B) pull(%B)\n"
          permissions.repository_permissions_admin
          permissions.repository_permissions_push
          permissions.repository_permissions_pull
      | None -> ()
    end;
    let branches = Repo.branches ~token ~user:"ocaml" ~repo:"opam" () in
    Stream.to_list branches
    >>= fun branches ->
    List.iter (fun b ->
      eprintf "branch %s %s\n"
        b.repo_branch_name
        b.repo_branch_commit.repo_commit_sha
    ) branches;
    return ()
  )

;;
Lwt_main.run t
