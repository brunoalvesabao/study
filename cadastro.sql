-- =========================================================
-- ACE · cadastro pelo próprio site
-- Rode UMA vez no Supabase: SQL Editor → New query → cole tudo → Run
--
-- Quando alguém cria conta pela tela "Criar conta", este gatilho cria o
-- perfil automaticamente, sempre como ALUNO e sem tutor. Ninguém consegue
-- virar tutor pelo site. Para ligar um aluno novo ao tutor, veja o fim do arquivo.
-- =========================================================

create or replace function public.criar_perfil_do_cadastro()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, nome, papel)
  values (
    new.id,
    coalesce(nullif(trim(new.raw_user_meta_data->>'nome'), ''), split_part(new.email, '@', 1)),
    'aluno'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists ao_criar_conta on auth.users;
create trigger ao_criar_conta
  after insert on auth.users
  for each row execute function public.criar_perfil_do_cadastro();


-- =========================================================
-- Opcional: ligar um aluno que se cadastrou pelo site ao tutor,
-- para ele aparecer na tela de Progresso do tutor.
-- Troque os e-mails e rode só este trecho.
-- =========================================================
-- update public.profiles
-- set tutor_id = (select id from auth.users where email = 'pai@example.com')
-- where id = (select id from auth.users where email = 'email-do-aluno@gmail.com');
